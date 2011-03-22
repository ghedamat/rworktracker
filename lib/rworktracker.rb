require 'yaml'
require 'time'
require 'date'

class RworkTrackerCli
  
  def initialize(file)
    @rw = RworkTracker.new(file)
    @rw.loadYaml
  end
  
  def help
    puts "Welcome to RworkTracker: Work Time Tracking Interface"
    puts "Available Commands are:"
    puts "\t pr, projects: list active projects"
    puts "\t add, addproject <projectname>, Add a new project"
    puts "\t start <project name>, Start tracking a project"
    puts "\t stop <project name>, Stop tracking a project"
    puts "\t stats, show total projects stats"
    puts "\t stat <project name>, show total project stats"
  end
  
  
  def projects
    puts "Active project are:"
    @rw.projects.each do |e| 
      puts e + " - running now" if @rw.started?(e) 
      puts e + " - not running now" if !@rw.started?(e) 
    end
  end

  def addproject
    if ARGV.length > 1 
      @rw.addProject(ARGV[1..-1].join('_'))
      @rw.writeYaml
    else
      warn "you need to provide a project name"
    end
  end

  def start
    if ARGV.length > 1 
      if @rw.start(ARGV[1..-1].join('_'))
        @rw.writeYaml
      else
        warn "please create the project first"
      end
    else
      warn "you need to provide a project name"
    end
  end

  def stop
    if ARGV.length > 1 
      if @rw.stop(ARGV[1..-1].join('_'))
        @rw.writeYaml
      else
        warn "please create the project first or start it !"
      end
    else
      warn "you need to provide a project name"
    end
  end

  def stat(pro = ARGV[1..-1].join('_'))
    if pro
      tot = @rw.elapsed(pro)
      if tot
        puts "Project #{pro} took #{Time.at(tot).gmtime.strftime('%R:%S')} hours" 
      else
        warn "please provide a valid project"
      end
    else
      warn "you need to provide a project name"
    end
  end

  def stats
    @rw.projects.each do |e|
      stat(e)
    end
  end

  def method_missing(m, *args, &block)  
    if ['pr','add'].include?(m.to_s)
      self.send  self.public_methods.grep(/#{m}/)[0] 
    else
      puts "There's no method called #{m} here"  
      help
    end
  end

end

class RworkTracker
  def initialize(yamlfile = nil)
    @yamlfile = yamlfile
    @wdata = Hash.new
    @time = Time.now
  end

  attr_accessor :yamlfile
  attr_reader :wdata

  def renewTime
    @time = Time.now
  end

  def loadYaml
    begin
    f = YAML.load(File.open(@yamlfile))
    rescue
    f = false
    end
    @wdata = ( f == false) ? Hash.new : f
    #check_status
  end

  def writeYaml
    File.open(@yamlfile, File::CREAT|File::TRUNC|File::RDWR) do |f|
      f << YAML::dump(@wdata)
    end
  end

  def projects
    @wdata.keys
  end

  def addProject(pro)
    @wdata[pro] ||= []
  end

  def started?(pro)
    begin
    if @wdata[pro].last['stop'] == nil
      return true
    else
      return false
    end
    rescue 
      return false
    end
  end
 
  def start(pro)
    return false unless @wdata[pro]
    @wdata[pro] << { 'start' => @time.to_s }
    return true
  end

  def stop(pro)
    return false unless @wdata[pro]
    if @wdata[pro].last.has_key?('start') and !@wdata[pro].last.has_key?('stop') 
      @wdata[pro].last.merge!({ 'stop' => @time.to_s })
      return true
    else
      return false
    end
  end

  def elapsed(pro)
    return false unless @wdata[pro]
    total = 0
    @wdata[pro].each  do |e|
      if e['stop']
        total += Time.parse(e['stop']) - Time.parse(e['start'])  
      elsif started?(pro)
        total += Time.now - Time.parse(e['start'])
      end
    end
    return total
  end
end
