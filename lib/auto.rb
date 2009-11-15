require File.dirname(__FILE__) + "/auto/require"

module Auto
  Runner.new { terminal($0) }
  exit
end
