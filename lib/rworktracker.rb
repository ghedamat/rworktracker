require 'yaml'
require 'time'

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
  end

  def writeYaml
    File.open(@yamlfile,'w', File::CREAT) do |f|
      f << YAML::dump(@wdata)
    end
  end

  def projects
    @wdata.keys
  end

  def addProject(pro)
    @wdata[pro] ||= Hash.new
  end

  def started?(pro)
    begin
    lm = @wdata[pro].keys.sort.last
    ld = @wdata[pro][lm].keys.sort.last
    if @wdata[pro][lm][ld].last['stop'] == nil
      return true
    else
      return false
    end
    rescue 
      #warn "Ill formed yaml file"
      #exit
      return false
    end
  end
 
  def start(pro)
    @wdata[pro][@time.month] ||= Hash.new
    @wdata[pro][@time.month][@time.day] ||= []
    @wdata[pro][@time.month][@time.day] << { 'start' => @time.to_s }
  end

  def stop(pro)
    @wdata[pro][@time.month] ||= Hash.new
    @wdata[pro][@time.month][@time.day] ||= []
    if @wdata[pro][@time.month][@time.day].last.has_key?('start') and @wdata[pro][@time.month][@time.day].last.has_key?('stop') == false
      @wdata[pro][@time.month][@time.day].last.merge!({ 'stop' => @time.to_s })
      return true
    else
      return false
    end
  end

  def elapsed(pro)
    total = 0
    @wdata[pro].each_value  do |m|
      m.each_value do |d|
        d.each do |e|
          total += Time.parse(e['stop']) - Time.parse(e['start']) 
        end
      end
    end
    return total
  end
end
