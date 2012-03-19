/*
	This file is part of Cocktail http://www.silexlabs.org/groups/labs/cocktail/
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktailCore.domElement.abstract;

import cocktail.domElement.ContainerDOMElement;
import core.nativeElement.NativeElement;
import core.nativeElement.NativeElementManager;
import cocktail.viewport.Viewport;
import cocktailCore.focus.FocusManager;
import cocktailCore.style.abstract.AbstractBodyStyle;
import cocktailCore.style.BodyStyle;

/**
 * This DOMElement is a secial ContainerDOMElement whose
 * NativeElement is always the root of the runtime (
 * for instance the Stage in Flash or the Body tag in
 * HTML.)
 * 
 * Some DOMElement behavior are not supported, like the
 * ability to set its width and height
 * 
 * @author Yannick DOMINGUEZ
 */
class AbstractBodyDOMElement extends ContainerDOMElement
{
	/**
	 * A reference to the view port used to listen for
	 * resize events
	 */
	private var _viewPort:Viewport;
	
	/**
	 * class constructor. Retrieve the root of the
	 * runtime and set it as this DOMElement's
	 * NativeElement
	 */
	public function new() 
	{
		super(NativeElementManager.getRoot());
	}
	
	/**
	 * Instantiate a Style specific to this
	 * DOMElement
	 */
	override private function initStyle():Void
	{
	//	_style = new BodyStyle(this);
		
		//instantiate the view port and listen
		//for resize on it
		_viewPort = new Viewport();
		_viewPort.onResize = onViewPortResize;
	}
	
	/**
	 * Overriden to set this as the reference
	 * to the BodyDOMElement of the focus manager,
	 * used to build the tab list tree
	 */
	override private function initFocus():Void
	{
		FocusManager.getInstance().bodyDOMElement = cast(this);
		super.initFocus();
	}
	
	/**
	 * When the view port is resized, insvalidate
	 * this BodyDOMElement to lay it out with
	 * the new view port dimensions
	 */
	private function onViewPortResize():Void
	{
		_style.invalidate();
	}
	
}