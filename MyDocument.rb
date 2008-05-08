#
#  MyDocument.rb
#  sqlite
#
#  Created by Brad Wilson on 19/04/08.
#  Copyright (c) 2008 __MyCompanyName__. All rights reserved.
#

require 'rubygems'
require 'pathname'
require 'sqlite3'
require 'TableViewMethods'
require 'OutlineViewMethods'

class MyDocument < NSDocument
	ib_outlets :tableView
	ib_outlets :tableContentView
	
	include TableViewMethods
	include OutlineViewMethods

  def windowNibName
    # Override returning the nib file name of the document If you need
    # to use a subclass of NSWindowController or if your document
    # supports multiple NSWindowControllers, you should remove this
    # method and override makeWindowControllers instead.
    return "MyDocument"
  end

  def windowControllerDidLoadNib(aController)
    super_windowControllerDidLoadNib(aController)
    # Add any code here that need to be executed once the
    # windowController has loaded the document's window.
		@mutex = Mutex.new
		watch_for_changes
		
		reload
  end

	###
	# Receives the filename to load the db from
	###
	def readFromURL_ofType_error(url, type, error)
		@file = url.to_s.gsub("file://localhost", '')
		
		error = nil
		return true
	end
	
	def isDocumentEdited
		# can't edit documents yet, so always no
		return false
	end
	
	###
	# action to handle table select
	###
	def showTable(sender)
		new_table = @table_names[sender.selectedRow]
		if new_table != @table
			@table = new_table
			load_rows_and_columns
			setup_table_columns
			
			#clear the sort descriptors because we're on a new table now
			@tableContentView.setSortDescriptors(NSArray.alloc.init)
			@tableContentView.reloadData
		end
  end
  ib_action :showTable

	
	###
	# Loads the db from file and populates the ui
	###
	def reload
		load_table_names
		load_rows_and_columns

		@tableView.reloadData
		@tableContentView.reloadData
	end
	
	###
	# Calls reload if the db file has been modified since last reload
	###
	def conditional_reload
		return if !File.exists?(@file)
		
		new_mtime = File.new(@file).mtime
		
		if @mtime.nil? || @mtime < new_mtime
			@mtime = new_mtime
			reload
		end
	end
	
	private

	###
	# Loads all data for the current table into instance variables:
	# @rows and @columns
	###
	def load_rows_and_columns
		if @table
			begin
				db = SQLite3::Database.new(@file, :results_as_hash => false, :type_translation => false)
				db.busy_timeout(100)
				sql = "select * from #{ @table }"
				sql += " order by #{ @order }" if @order and @order.strip != ''
			
				result = db.execute2(sql)
				@columns = result.shift
				@rows = result
			rescue SQLite3::SQLException => e
				puts e
			end
			
			db.close
		end
	end
	
	###
	# Return all tables in the current db
	###
	def load_table_names
		db = SQLite3::Database.new(@file, :results_as_hash => false, :type_translation => false) 
		db.busy_timeout(100)
		result = db.execute2("select name from sqlite_master where type in ('table', 'view') and name not like 'sqlite_%' order by name")
		result.shift # throw away columns

		@table_names = result.inject([]) do |array, row|
			name = row.first
			str = NSMutableString.alloc.initWithCapacity(name.length)
			str.setString(name)
			array << str
		end
		db.close
	end
	
	###
	# Sets up the table content viewer to have the columns
	# named in the current table
	###
	def setup_table_columns
		while !(columns = @tableContentView.tableColumns).empty?
			@tableContentView.removeTableColumn(columns.first)
		end
		
		@columns.each_with_index do |name, i|
			column = NSTableColumn.alloc.initWithIdentifier(i)
			column.headerCell.setStringValue(name)
			column.setEditable(false)
			sort = NSSortDescriptor.alloc.initWithKey_ascending_selector(name, true, "localizedCaseInsensitiveCompare:")
			column.setSortDescriptorPrototype(sort)

			@tableContentView.addTableColumn(column)
		end
	end
	
	
	###
	# Keeps an eye on the filesytem and reloads the db when there are changes to the db
	###
	def watch_for_changes
		NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(1.0, self, 'conditional_reload:', nil, true).retain
	end

end
