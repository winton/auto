require File.dirname(__FILE__) + "/auto/require"

module Auto
  Runner.new do
    terminal($0)
  end
  exit
end
