////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;
import mx.accessibility.AccConst;
import mx.controls.DateChooser;
import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  DateChooserAccImpl is a subclass of AccessibilityImplementation
 *  which implements accessibility for the DateChooser class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DateChooserAccImpl extends AccImpl
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Enables accessibility in the DateChooser class.
	 * 
	 *  <p>This method is called by application startup code
	 *  that is autogenerated by the MXML compiler.
	 *  Afterwards, when instances of DateChooser are initialized,
	 *  their <code>accessibilityImplementation</code> property
	 *  will be set to an instance of this class.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function enableAccessibility():void
	{
		DateChooser.createAccessibilityImplementation =
			createAccessibilityImplementation;
	}

	/**
	 *  @private
	 *  Creates a DateChooser's AccessibilityImplementation object.
	 *  This method is called from UIComponent's
	 *  initializeAccessibility() method.
	 */
	mx_internal static function createAccessibilityImplementation(
								component:UIComponent):void
	{
		component.accessibilityImplementation =
			new DateChooserAccImpl(component);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  @param master The UIComponent instance that this AccImpl instance
	 *  is making accessible.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function DateChooserAccImpl(master:UIComponent)
	{
		super(master);

		role = AccConst.ROLE_SYSTEM_WINDOW;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var calFlag:Boolean = true;
	
	/**
	 *  @private
	 */
	private var monthFlag:Boolean = true;

	/**
	 *  @private
	 */
	private var lastSelectedDate:Date;

	/**
	 *  @private
	 */
	private var selDateFallsInCurrMonth:Boolean;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden properties: AccImpl
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  eventsToHandle
	//----------------------------------

	/**
	 *  @private
	 *	Array of events that we should listen for from the master component.
	 */
	override protected function get eventsToHandle():Array
	{
		return super.eventsToHandle.concat([ "focusIn", "change", "scroll"]);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccessibilityProperties
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  IAccessible method for returning the state of the DateChooser.
	 *  States are predefined for all the components in MSAA.
	 *
	 *  @param childID uint
	 *
	 *  @return State uint
	 */
	override public function get_accState(childID:uint):uint
	{
		return getState(childID);
	}

	/**
	 *  @private
	 *  IAccessible method for executing the Default Action.
	 *
	 *  @param childID uint
	 */
	override public function accDoDefaultAction(childID:uint):void
	{
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  method for returning the name of the DateChooser
	 *  should return the selected date with weekday, month and year.
	 *  appends 'today' if selected date is also today date.
	 *
	 *  @param childID uint
	 *
	 *  @return Name String
	 */
	override protected function getName(childID:uint):String
	{
		var name:String;
		
		var dateChooser:DateChooser = DateChooser(master);
		
		var selDate:Date = dateChooser.selectedDate;
		
		selDateFallsInCurrMonth =
			selDate != null &&
			selDate.getMonth() == dateChooser.displayedMonth &&
			selDate.getFullYear() == dateChooser.displayedYear;

		if (selDate != null && selDateFallsInCurrMonth)
		{
			if (monthFlag)
			{
				name = "" + selDate.getDate() + " " +
					   dateChooser.dayNames[selDate.getDay()] + ", " +
					   dateChooser.monthNames[dateChooser.displayedMonth] + " " +
					   dateChooser.displayedYear;
			}
			else
			{
				name = "" + selDate.getDate() + " " +
					   dateChooser.dayNames[selDate.getDay()];
			}

			var todayDate:Date = new Date();
			
			if (todayDate.getDate() == selDate.getDate() &&
				todayDate.getMonth() == selDate.getMonth() &&
				todayDate.getFullYear() == selDate.getFullYear())
			{
				name += ", today";
			}
		}
		else
		{
			name = dateChooser.monthNames[dateChooser.displayedMonth] + " " +
				   dateChooser.displayedYear;
		}

		if (calFlag)
			name = " Calendar View, " + name;
			
		return name;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Override the generic event handler.
	 *  All AccImpl must implement this to listen
	 *  for events from its master component. 
	 */
	override protected function eventHandler(event:Event):void
	{
		// Let AccImpl class handle the events
		// that all accessible UIComponents understand.
		$eventHandler(event);

		var dateChooser:DateChooser = DateChooser(master);

		var randomDate:int = dateChooser.displayedMonth + dateChooser.displayedYear;

		switch (event.type)
		{
			case "focusIn":
			{
				calFlag = true;
				monthFlag = true;
				break;
			}

			case "change":
			{
				calFlag = false;
				
				var selDate:Date = dateChooser.selectedDate;
				if (selDate)
				{
					if (lastSelectedDate)
						monthFlag =  lastSelectedDate.getDate() == selDate.getDate();

					Accessibility.sendEvent(master,
											randomDate + selDate.getDate() + 100,
											AccConst.EVENT_OBJECT_FOCUS);
					
					Accessibility.sendEvent(master,
											randomDate + selDate.getDate() + 100,
											AccConst.EVENT_OBJECT_SELECTION);
				}
				lastSelectedDate = selDate;

				break;
			}

			case "scroll":
			{
				calFlag = false;
				monthFlag = true;

				Accessibility.sendEvent(master, randomDate,
										AccConst.EVENT_OBJECT_FOCUS);

				Accessibility.sendEvent(master, randomDate,
										AccConst.EVENT_OBJECT_SELECTION);

				break;
			}
		}
	}
}

}
