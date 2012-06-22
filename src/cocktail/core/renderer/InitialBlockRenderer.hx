/*
	This file is part of Cocktail http://www.silexlabs.org/groups/labs/cocktail/
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktail.core.renderer;

import cocktail.core.background.BackgroundManager;
import cocktail.core.dom.Node;
import cocktail.core.html.HTMLElement;
import cocktail.core.NativeElement;
import cocktail.core.geom.GeomData;
import cocktail.core.style.formatter.BlockFormattingContext;
import cocktail.core.style.formatter.FormattingContext;
import cocktail.core.style.StyleData;
import cocktail.core.style.CoreStyle;
import haxe.Log;
import cocktail.core.renderer.RendererData;
import cocktail.core.font.FontData;
import haxe.Timer;

/**
 * This is the root ElementRenderer of the rendering
 * tree, generated by the HTMLHTMLElement, which is the root
 * of the DOM tree
 * 
 * TODO 3 : update doc
 * 
 * @author Yannick DOMINGUEZ
 */
class InitialBlockRenderer extends BlockBoxRenderer
{
	
	
	private static inline var INVALIDATION_INTERVAL:Int = 2000;
	
	private var _invalidationScheduled:Bool;
	
	/**
	 * class constructor.
	 */
	public function new(node:HTMLElement) 
	{
		super(node);
		
		_invalidationScheduled = false;
		
		//call the attachement method itself as it is 
		//supposed to be called by parent ElementRenderer
		//otherwise
		attach();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PUBLIC INVALIDATION METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * The initial block renderer doesn't have a parent, so when invalidated,
	 * it always starts a layout
	 */
	private function invalidateLayout(immediate:Bool = false):Void
	{
		if (_invalidationScheduled == false || immediate == true)
		{
			_invalidationScheduled = true;
			doInvalidate(immediate);
		}
	}
	
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE ATTACHEMENT METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	override private function attachLayer():Void
	{
		_layerRenderer = new LayerRenderer(this);
	}
	
	override private function detachLayer():Void
	{
		_layerRenderer = null;
	}
	
	override private function attachContaininingBlock():Void
	{
		
	}
	
	override private function detachContainingBlock():Void
	{
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PUBLIC METHOD
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * The Document is invalidated for instance when the
	 * DOM changes after adding/removing a child or when
	 * a style changes.
	 * When this happen, the Document needs to be laid out
	 * and rendered again
	 * 
	 * @param immediate define wether the layout must be synchronous
	 * or asynchronous
	 */
	private function doInvalidate(immediate:Bool = false):Void
	{
		//either schedule an asynchronous layout and rendering, or layout
		//and render immediately
		if (immediate == false)
		{
			scheduleLayoutAndRender();
		}
		else
		{
			layoutAndRender();
		}
	}
	
	override private function invalidateContainingBlock(invalidationReason:InvalidationReason):Void
	{
		_needsLayout = true;
		_childrenNeedLayout = true;
		_needsVisualEffectsRendering = true;
		_needsRendering = true;
		_positionedChildrenNeedLayout = true;
		
		switch (invalidationReason)
		{
			case InvalidationReason.needsImmediateLayout:
				invalidateLayout(true);
				
			default:
				invalidateLayout(false);
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PRIVATE RENDERING METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * As the name implies,
	 * layout the DOM, then render it
	 */
	private function layoutAndRender():Void
	{
		startLayout();
		startRendering();
		_invalidationScheduled = false;
	}
	
	/**
	 * Start the rendering of the rendering tree
	 * built during layout
	 * and attach the resulting nativeElements (background,
	 * border, embedded asset...) to the display root
	 * of the runtime (for instance the Stage in Flash)
	 */ 
	private function startRendering():Void
	{
		#if (flash9 || nme)
		//start the rendering at the root layer renderer
		//TODO 3 : should instead call an invalidateRendering method on LayerRenderer ?
		render(flash.Lib.current);
		#end
	}
	
	/**
	 * Start the layout of all of the HTMLElements tree which set the bounds
	 * of the all of the rendring tree elements relative to their containing block.
	 * Then set the global bounds (relative to the window) for all of the elements
	 * of the rendering tree
	 * 
	 * TODO 2 : for now only called by the InitialBlockRenderer but should be callable
	 * by any BoxRenderer to prevent from laying out and rendering all of the rendering
	 * tree
	 */
	private function startLayout():Void
	{
		//layout all the HTMLElements. After that they all know their bounds relative to the containing
		//blocks
		layout();
		//set the global bounds on the rendering tree. After that all the elements know their positions
		//relative to the window
		setGlobalOrigins(this,0,0, 0,0);
	}
	
	/**
	 * Set the global bounds (relative to the window) of all the elements of the rendering tree, by
	 * traversing it recursively
	 * 
	 * 
	 * @param	elementRenderer the current node in the render tree onto which the global bounds are set
	 * @param	addedX the added x position for the normal flow
	 * @param	addedY the added y position for the normal flow
	 * @param	addedPositionedX the added X position for positioned elements
	 * @param	addedPositionedY the added Y position for positioned elements
	 */
	private function setGlobalOrigins(elementRenderer:ElementRenderer, addedX:Float, addedY:Float, addedPositionedX:Float, addedPositionedY:Float):Void
	{
		//if the element establishes a new formatting context, then its
		//bounds must be added to the global x and y bounds for the normal flow
		if (elementRenderer.establishesNewFormattingContext() == true)
		{
			//if the element is positioned, it can either add its bounds
			//or positioned origin to the global x and y for normal flow. If it
			//uses its static position, it uses its bounds, else it uses its
			//positioned origin
			if (elementRenderer.isPositioned() == true && elementRenderer.isRelativePositioned() == false)
			{
				if (elementRenderer.coreStyle.left != PositionOffset.cssAuto || elementRenderer.coreStyle.right != PositionOffset.cssAuto)
				{
					//when the element id absolutely positioned and not static, it uses
					//its own global bounds as the new origin for its children
					//TODO 1 : should check for regression, pretty big change
					if (elementRenderer.coreStyle.computedStyle.position == absolute)
					{
						addedX = elementRenderer.globalBounds.x;
					}
					//here the positioned ElementRenderer is fixed and is placed
					//relative to the window. In this case, its x is not added
					else
					{
						addedX = elementRenderer.positionedOrigin.x;
					}
				}
				else
				{
					addedX += elementRenderer.bounds.x;
				}
				
				if (elementRenderer.coreStyle.top != PositionOffset.cssAuto || elementRenderer.coreStyle.bottom != PositionOffset.cssAuto)
				{
					if (elementRenderer.coreStyle.computedStyle.position == absolute)
					{
						addedY = elementRenderer.globalBounds.y;
					}
					else
					{
						addedY = elementRenderer.positionedOrigin.y;
					}
				}
				else
				{
					addedY += elementRenderer.bounds.y;
				}
			}
			//if the element is not positioned or relatively positioned, it always add
			//its bounds to the global x and y flow
			else
			{
				addedX += elementRenderer.bounds.x;
				addedY += elementRenderer.bounds.y;
			}
			
		}
		
		//if the element is positioned, it must also add
		//its bounds to the global positioned origin
		if (elementRenderer.isPositioned() == true)
		{
			//absolutely positioned elements either add their static position
			//or their positioned origin
			if (elementRenderer.coreStyle.computedStyle.position != relative)
			{
				if (elementRenderer.coreStyle.left != PositionOffset.cssAuto || elementRenderer.coreStyle.right != PositionOffset.cssAuto)
				{
					if (elementRenderer.coreStyle.computedStyle.position == absolute)
					{
						addedPositionedX += elementRenderer.positionedOrigin.x;
					}
					else
					{
						addedPositionedX = elementRenderer.positionedOrigin.x;
					}
				}
				else
				{
					addedPositionedX += elementRenderer.bounds.x;
				}
				if (elementRenderer.coreStyle.top != PositionOffset.cssAuto || elementRenderer.coreStyle.bottom != PositionOffset.cssAuto)
				{
					if (elementRenderer.coreStyle.computedStyle.position == absolute)
					{
						addedPositionedY += elementRenderer.positionedOrigin.y;
					}
					else
					{
						addedPositionedY = elementRenderer.positionedOrigin.y;
					}
					
				}
				else
				{
					addedPositionedY += elementRenderer.bounds.y;
				}
			}
			//relative positioned elements always use their bounds, as the relative
			//offset is only applied at render time and isn't used in the bounds
			//computation
			else
			{
				addedPositionedX += elementRenderer.bounds.x;
				addedPositionedY += elementRenderer.bounds.y;
			}
		}
		
		//for its child of the element
		var length:Int = elementRenderer.childNodes.length;
		for (i in 0...length)
		{
			var child:ElementRenderer = elementRenderer.childNodes[i];
			
			child.globalContainingBlockOrigin = {
				x: addedX,
				y : addedY
			}
			
			child.globalPositionnedAncestorOrigin = {
				x: addedPositionedX,
				y : addedPositionedY
			}
			
			//call the method recursively if the child has children itself
			if (child.hasChildNodes() == true)
			{
				setGlobalOrigins(child, addedX, addedY, addedPositionedX, addedPositionedY);
			}
		}
	}
	
	/**
	 * Set a timer to trigger a layout and rendering of the HTML Document asynchronously.
	 * Setting a timer to execute the layout and rendering ensure that the layout only happen once when a series of style
	 * values are set or when many elements are attached/removed from the DOM, instead of happening for every change.
	 */
	private function scheduleLayoutAndRender():Void
	{
		var layoutAndRenderDelegate:Void->Void = layoutAndRender;
		#if (flash9 || nme)
		//calling the methods 1 millisecond later is enough to ensure
		//that first all synchronous code is executed
		Timer.delay(function () { 
			layoutAndRenderDelegate();
		}, INVALIDATION_INTERVAL);
		#end
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PUBLIC HELPER METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * The initial block renderer is always considered positioned,
	 * as it always lays out the positioned children for whom it is
	 * the first positioned ancestor
	 */
	override public function isPositioned():Bool
	{
		return true;
	}
	
	/**
	 * The initial block container always establishes a block formatting context
	 * for its children
	 */
	override public function establishesNewFormattingContext():Bool
	{
		return true;
	}
	
	/**
	 * Overriden as initial block container alwyas establishes a new
	 * stacking context and creates the root LayerRenderer of the
	 * LayerRenderer tree
	 */
	override public function establishesNewStackingContext():Bool
	{
		return true;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN PRIVATE HELPER METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	override private function getScrollbarContainerBlock():ContainingBlockData
	{
		var width:Float = cocktail.Lib.window.innerWidth;
		var height:Float = cocktail.Lib.window.innerHeight;
		
		var windowData:ContainingBlockData = {
			isHeightAuto:false,
			isWidthAuto:false,
			width:width,
			height:height
		}
		
		return windowData;
	}
	
	/**
	 * When dispatched on the HTMLBodyElement,
	 * the scroll event must bubble to be dispatched
	 * on the Document and Window objects
	 * 
	 * TODO 3 : must be moved to the renderer of the HTMLBodyElement,
	 * or should it be moved to an override of dispatchEvent in HtmlBodyElement ?
	 */
	override private function mustBubbleScrollEvent():Bool
	{
		return true;
	}
	
	/**
	 * A computed value of visible for the overflow on the initial
	 * block renderer is the same as auto, as it is likely that
	 * scrollbar must be displayed to scroll through the document
	 */
	override private function treatVisibleOverflowAsAuto():Bool
	{
		return true;
	}
	
	/**
	 * Retrieve the dimension of the Window
	 */
	override private function getWindowData():ContainingBlockData
	{	
		var width:Float = cocktail.Lib.window.innerWidth;
		var height:Float = cocktail.Lib.window.innerHeight;
		
		var windowData:ContainingBlockData = {
			isHeightAuto:false,
			isWidthAuto:false,
			width:width,
			height:height
		}
		
		//scrollbars dimension are removed from the Window dimension
		//if displayed to return the actual available space
		
		if (_verticalScrollBar != null)
		{
			windowData.width -= _verticalScrollBar.coreStyle.computedStyle.width;
		}
		
		if (_horizontalScrollBar != null)
		{
			windowData.height -= _horizontalScrollBar.coreStyle.computedStyle.height;
		}
		
		return windowData;
	}
	
	/**
	 * The dimensions of the initial
	 * block renderer are always the same as the Window
	 */
	override public function getContainerBlockData():ContainingBlockData
	{
		return getWindowData();
	}
	
	override private function getContainingBlock():FlowBoxRenderer
	{	
		return this;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// OVERRIDEN GETTER
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * overriden as the bounds of the initial block container
	 * are always those of the Window (minus scrollbars dimensions
	 * if displayed)
	 */
	override private function get_bounds():RectangleData
	{
		var containerBlockData:ContainingBlockData = getContainerBlockData();
		
		var width:Float = containerBlockData.width;
		var height:Float = containerBlockData.height;
		
		return {
			x:0.0,
			y:0.0,
			width:width,
			height:height
		};
	}
	
	/**
	 * For the initial container, the bounds and
	 * global bounds are the same
	 */
	override private function get_globalBounds():RectangleData
	{
		return bounds;
	}
	
}