/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package ;
import js.Lib;


class Test 
{
	public static function main()
	{	
		new Test();
	}
	
	public function new()
	{
		// TODO borders to add
		var test = '';
		test += '<div>';
		test += 	'<p>Below, there should be 2 orange boxes horizontally centered within their respective green bars.</p>';
		test += 	'<div style="background-color: green; margin: 1em;">';
		test += 		'<input type="button" value="         " style="background-color: orange; display: block; margin-left: auto; margin-right: auto; width: auto;"/>';
		test += 	'</div>';
		test += 	'<form action="">';
		test += 		'<div style="background-color: green; margin: 1em;">';
		test += 			'<input type="submit" value="         " style="background-color: orange; display: block; margin-left: auto; margin-right: auto; width: auto;"/>';
		test += 		'</div>';
		test += 	'</form>';
		test += '</div>';
		
		Lib.document.body.innerHTML = test;
	}
}