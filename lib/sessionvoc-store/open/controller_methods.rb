module ControllerMethods
  module InstanceMethods
    # Workaround used to create a new rack session because rack sessions are being created
    # lazily and the usage of some of the sessionvoc methods might fail if no rack session
    # exists.
    def init_sessionvoc
      session['sessionvoc-init'] = true
    end
  end
end
