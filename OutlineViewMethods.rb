#
#  OutlineViewMethods.rb
#  sqlite
#
#  Created by Brad Wilson on 2/05/08.
#  Copyright (c) 2008 Brad Wilson. All rights reserved.
#

module OutlineViewMethods
  # (id)
  def outlineView_child_ofItem(outlineView, index, item)
		return @table_names[index]
  end
  
  # (bool)
  def outlineView_isItemExpandable(outlineView, item) 
    return false
  end
  
  # (bool)
  def outlineView_numberOfChildrenOfItem(outlineView, item)
		return (item.nil? ? @table_names.length : 0)
  end
  
  # (id)
  def outlineView_objectValueForTableColumn_byItem(outlineView, tableColumn, item)
		return item
	end
end
