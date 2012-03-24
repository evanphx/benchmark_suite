require "test/unit"
require "benchmark_suite"

class TestBenchmarkSuite < Test::Unit::TestCase
  def test_ips
    s = Benchmark::Suite.create do |s|
      s.quiet!

      Benchmark.ips(1,1) do |x|
        x.report("sleep") { sleep(0.25) }
      end
    end

    rep = s.report.first

    assert_equal "sleep", rep.label
    assert_equal 4, rep.iterations
    assert_in_delta 4.0, rep.ips, 0.2
  end
end
