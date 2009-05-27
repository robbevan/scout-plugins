class MongrelClusterMonitor < Scout::Plugin
  def run
    unless app_name = @options["app_name"]
      raise "app_name must be specified"
    end
    unless rails_root = @options["rails_root"]
      raise "rails_root must be specified"
    end
    mongrel_rails_command = @options["mongrel_rails_command"] || "mongrel_rails"
    to_return = { :alerts => [], :report => {}, :memory => {} }
    Dir.chdir(rails_root) do
      mongrel_status = `#{mongrel_rails_command} cluster::status`
      if mongrel_status.empty? 
        raise "mongrel_rails command: `#{mongrel_rails_command}` not found or no status information available"
      elsif mongrel_status.include?("missing")
        unless @memory[app_name]
          to_return[:alerts] << { :subject => "#{app_name} has missing mongrels" }
          to_return[:alerts] << { :body => "#{mongrel_status.grep(/missing/)}" }
          to_return[:report][app_name] = 0
          to_return[:memory][app_name] = Time.now
        end
      else
        to_return[:report][app_name] = 1
        to_return[:memory][app_name] = nil
      end
    end
    return to_return  
  rescue Exception
    { :error => { :subject => "Couldn't monitor the mongrel cluster.",
                  :body    => "An exception was thrown:  #{$!.message}" } }
  end
end