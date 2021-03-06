module RubyMotionQuery
  class RMQ
    # @return [Device]
    def device
      Device
    end

    # @return [Device]
    def self.device
      Device
    end
  end

  class Device
    class << self
      # Find out what version of iOS you're using.
      # `rmq.device.is_version? 8`
      # `rmq.device.is_version? "7.1"`
      #
      # @return [Boolean]
      def is_version? version
        !!ios_version.match("^#{version}")
      end

      def ios_version
        UIDevice.currentDevice.systemVersion
      end

      # Identify if current version is at least that of what is passed.
      # Will not work if apple ever does semantic versions like 8.2.1
      # `rmq.device.ios_at_least? 8`
      # `rmq.device.ios_at_least? 7.1`
      #
      # @return [Boolean]
      def ios_at_least? version
        version.to_f.round(3) <= ios_version.to_f.round(3)
      end

      # @return [UIScreen]
      def screen
        UIScreen.mainScreen
      end

      def size_a
        @_size_a ||= screen.bounds.size.to_a.sort
      end

      # Width is the width of the device, regardless of its orientation.
      # This is static. If you want the width with the correct orientation, use
      # screen_width
      #
      # @return [Numeric]
      def width
        size_a[0]
      end
      def width_landscape
        size_a[1]
      end

      # Height is the height of the device, regardless of its orientation.
      # This is static. If you want the height with the correct orientation, use
      # screen_height
      #
      # @return [Numeric]
      def height
        size_a[1]
      end
      def height_landscape
        size_a[0]
      end

      # @return [Numeric]
      def screen_width
        portrait? ? width : width_landscape
      end

      # @return [Numeric]
      def screen_height
        portrait? ? height : height_landscape
      end

      def ipad?
        @_ipad = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) if @_ipad.nil?
        @_ipad
      end

      def iphone?
        @_iphone = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) if @_iphone.nil?
        @_iphone
      end

      def simulator?
        if @_simulator.nil?
          @_simulator = !(UIDevice.currentDevice.name.downcase =~ /simulator/).nil?
        end
        @_simulator
      end

      def three_point_five_inch?
        @_three_point_five_inch = (Device.height == 480.0) if @_three_point_five_inch.nil?
        @_three_point_five_inch
      end

      def four_inch?
        @_four_inch = (Device.height == 568.0) if @_four_inch.nil?
        @_four_inch
      end

      def four_point_seven_inch?
        @_four_point_seven_inch = (Device.height == 667.0) if @_four_point_seven_inch.nil?
        @_four_point_seven_inch
      end

      def five_point_five_inch?
        @_five_point_five_inch = (Device.height == 736.0) if @_five_point_five_inch.nil?
        @_five_point_five_inch
      end

      def twelve_point_nine_inch?
        @_twelve_point_nine_inch = (Device.height == 1366.0) if @_twelve_point_nine_inch.nil?
        @_twelve_point_nine_inch
      end

      def retina?
        if @_retina.nil?
          main_screen = Device.screen
          @_retina = !!(main_screen.respondsToSelector('displayLinkWithTarget:selector:') && main_screen.scale == 2.0)
        end

        @_retina
      end

      # @return :unknown or from ORIENTATIONS
      def orientation
        if @custom_orientation
          @custom_orientation
        else
          orientation = UIApplication.sharedApplication.statusBarOrientation
          ORIENTATIONS[orientation] || :unknown
        end
      end

      # You can manually set the orientation, if set it RMQ won't automatically get the
      # orientation from the sharedApplication. If you want the automatic orientation to work again
      # set this to nil
      #
      # For options of what to set it to, see RubyMotionQuery::Device::ORIENTATIONS
      #
      # You can set this to :landscape, which isn't real option, but it will automatically
      # get converted to :landscape_left
      def orientation=(value)
        if value
          if value == :landscape
            value = :landscape_left
          elsif !value.is_a?(Symbol)
            value = ORIENTATIONS[value] || :unknown
          end
        end
        @custom_orientation = value
      end

      def landscape?
        orientated = orientation
        orientated == :landscape || orientated == :landscape_left || orientated == :landscape_right
      end

      def portrait?
        orientated = orientation
        orientated == :portrait || orientated == :unknown || orientated == :portrait_upside_down
      end

      def orientations
        ORIENTATIONS
      end

      ORIENTATIONS = {
        UIDeviceOrientationUnknown => :unknown,
        UIDeviceOrientationPortrait => :portrait,
        UIDeviceOrientationPortraitUpsideDown => :portrait_upside_down,
        UIDeviceOrientationLandscapeLeft => :landscape_left,
        UIDeviceOrientationLandscapeRight => :landscape_right,
        UIDeviceOrientationFaceUp => :face_up,
        UIDeviceOrientationFaceDown => :face_down
      }

      def log
        puts "Device Info:\n" << "-" * 12
        [:simulator?, :orientation, :retina?, :screen_height, :screen_width, :ios_version].each do |method|
          puts "#{method}: #{self.send(method)}"
        end

        if five_point_five_inch?
          puts "screen size: 5.5\""
        elsif four_point_seven_inch?
          puts "screen size: 4.7\""
        elsif four_inch?
          puts "screen size: 4\""
        elsif three_point_five_inch?
          puts "screen size: 3.5\""
        elsif twelve_point_nine_inch?
          puts "screen size: 12.9\""
        end
      end

    end
  end
end
