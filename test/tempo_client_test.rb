require_relative "test_helper"

module TempoTest
  class Session < Test::Unit::TestCase

    setup do
      @tempdir = Dir.mktmpdir
    end

    teardown do
      FileUtils.rm_rf(@tempdir)
    end

    context "Timer" do
      test "should be able to read and write a timestamp" do
        timer = Tempo::Timer.new(@tempdir)

        Timecop.travel(2008, 10, 10, 10, 10, 10) do 
          timer.write_timestamp
          assert_equal Time.now.utc.to_s, timer.read_timestamp
        end
      end

      test "should be able to determine elapsed time since last timestamp" do
        timer = Tempo::Timer.new(@tempdir)

        Timecop.travel(2008, 10, 10, 10, 10, 10) do
          timer.write_timestamp
          Timecop.travel(2008, 10, 10, 10, 40, 10) do
            assert_equal 0.5, timer.elapsed_time
          end
        end
      end

      test "should be able to clear timestamp" do
        timer = Tempo::Timer.new(@tempdir)
        timer.write_timestamp
        timer.clear_timestamp
        assert_raises(Tempo::Timer::MissingTimestampError) do
          timer.read_timestamp
        end
      end

      test "should be able to check to see if a timestamp exists" do
        timer = Tempo::Timer.new(@tempdir)
        assert !timer.running?
        timer.write_timestamp

        assert timer.running?

        timer.clear_timestamp

        assert !timer.running?
      end
    end


    context "Queue" do
      test "should be able to add, compute, and clear times" do
        queue = Tempo::Queue.new(@tempdir)

        queue << 10
        queue << 15.5
        queue << 20

        assert_equal 45.5, queue.compute
        assert_equal 45.5, queue.compute

        queue.clear

        queue << 18
        queue << 2.25

        assert_equal 20.25, queue.compute
      end

      test "should be able to tell when the queue is empty" do
        queue = Tempo::Queue.new(@tempdir)

        assert queue.empty?

        queue << 21
        assert !queue.empty?

        queue.clear
        assert queue.empty?
      end

      test "should raise an error if compute is called with an empty queue" do
        queue = Tempo::Queue.new(@tempdir)
        assert_raises(Tempo::Queue::EmptyQueueError) do
          queue.compute
        end
      end

    end
  end
end
