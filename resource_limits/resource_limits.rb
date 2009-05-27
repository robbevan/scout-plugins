class ResourceLimits < Scout::Plugin
  def build_report
    zonename = `zonename`
    prstat_output = `prstat -Z -s rss 1 1`.grep(/#{zonename.chomp}/).first.gsub(/\s{2,}/, ' ').strip.split(" ")
    rss = prstat_output[3].gsub(/M/, '').to_i
    swap = prstat_output[2].gsub(/M/, '').to_i
    report(:rss => rss)
    report(:swap => swap)
  rescue => e
    error("Couldn't use `prstat` as expected.", "#{e.message} ----- #{e.backtrace}")
  end
end