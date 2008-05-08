#
#  TableViewMethods.rb
#  sqlite
#
#  Created by Brad Wilson on 2/05/08.
#  Copyright (c) 2008 Brad Wilson. All rights reserved.
#

module TableViewMethods

	def numberOfRowsInTableView(aTableView)
		@rows ? @rows.length : 0
	end

	###
	# Returns the value to display for the given row and column
	###
	def tableView_objectValueForTableColumn_row(afileTable, aTableColumn, rowIndex)
		colIndex = aTableColumn.identifier.to_i
		return @rows[rowIndex][colIndex] if @rows and rowIndex < @rows.length and colIndex < @rows[rowIndex].length
	end
	
	###
	# Update order for sql query, and force a reload
	###
	def tableView_sortDescriptorsDidChange(aTableView, oldDescriptors)
		sort_descriptors = aTableView.sortDescriptors
		puts sort_descriptors
		puts oldDescriptors
		@order = ""
		@order = sort_descriptors.map { |sd| "lower(#{ sd.key }) #{ sd.ascending ? 'asc' : 'desc' }" }.join(', ') if sort_descriptors.any?

		reload
	end
end
