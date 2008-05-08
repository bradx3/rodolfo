include OSX

###
# Handles code to be run at application startup
###
class StartupController < NSObject

	def applicationDidFinishLaunching(notification)
		# show an open dialog after load
		NSDocumentController.sharedDocumentController.openDocument(nil)
	end

end