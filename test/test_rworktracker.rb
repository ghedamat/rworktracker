require 'helper'
require 'pp'

class TestRworkTracker < Test::Unit::TestCase
  
  def setup
    @file = 'test/files/work.yaml'
  end

  should "load a yaml file" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    assert_equal rwt.wdata.class, Hash
  end
  
  should "say no if starting a nonexisting project" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    assert_equal false,rwt.start('ciao')
    
  end
  should "write yaml file" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    rwt.writeYaml
    rwt2 = RworkTracker.new(@file)
    rwt2.loadYaml
    assert_equal rwt.wdata, rwt2.wdata
  end
  
  should "list projects" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    assert_equal ['home','work','exi'], rwt.projects
  end

  should "add a project" do
    rwt = RworkTracker.new()
    rwt.addProject('newprj') 
    assert_equal ['newprj'], rwt.projects
  end

  should "start a new working session" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    rwt.addProject('newprj') 
    rwt.start('newprj')
    assert_equal true, rwt.started?('newprj')
  end
  
  should "stop a started project" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    rwt.addProject('newprj') 
    rwt.start('newprj')
    assert_equal true, rwt.stop('newprj')
  end

  should "not stop a project already stopped" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    rwt.addProject('newprj') 
    rwt.start('newprj')
    rwt.stop('newprj')
    assert_equal false, rwt.stop('newprj')
  end
    
  should "say if a project is in started state" do
    rwt = RworkTracker.new(@file)
    rwt.loadYaml
    rwt.addProject('newprj') 
    rwt.start('newprj')
    rwt.stop('newprj')
    assert_equal false, rwt.started?('newprj')
  end

  should "calculate total time spent on a project in seconds" do
    rwt = RworkTracker.new()
    rwt.addProject('newprj')
    rwt.start('newprj')
    sleep 1
    rwt.renewTime
    rwt.stop('newprj')
    sleep 2
    rwt.renewTime
    rwt.start('newprj')
    sleep 1
    rwt.renewTime
    rwt.stop('newprj')
    assert_equal 2, rwt.elapsed('newprj')
  end


end
