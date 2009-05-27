class ResourceLimits < Scout::Plugin
  def run
    zonename = `zonename`
    max_rss = @options["max_rss"].to_i
    max_swap = @options["max_swap"].to_i
    prstat_output = `prstat -Z -s rss 1 1`.grep(/#{zonename.chomp}/).first.gsub(/\s{2,}/, ' ').strip.split(" ")
    report = {:report => Hash.new, :alerts => Array.new}
    report[:report][:rss] = prstat_output[3].gsub(/M/, '').to_i
    report[:report][:swap] = prstat_output[2].gsub(/M/, '').to_i
    if report[:report][:rss] > max_rss
      report[:alerts] << { :subject => "Max RSS Exceeded: #{report[:report][:rss]}(#{max_rss})" }
    end
    if report[:report][:swap] > max_swap
      report[:alerts] << { :subject => "Max SWAP Exceeded: #{report[:report][:swap]}(#{max_swap})" }
    end
    report
  rescue
    { :error => { :subject => "Couldn't use `prstat` as expected.",
                  :body    => $!.message } }
  end
end