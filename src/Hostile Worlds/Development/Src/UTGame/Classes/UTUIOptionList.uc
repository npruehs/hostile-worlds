/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 *
 * Options tab page, autocreates a set of options widgets using the datasource provided.
 */

class UTUIOptionList extends UDKUIOptionList
	placeable;

defaultproperties
{
	DefaultStates.Add(class'Engine.UIState_Active')
	BGPrefab=UIPrefab'UI_Scenes_FrontEnd.Prefabs.OptionBG'
	SelectionImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseD'
	ArrowImage=Texture2D'UI_HUD.HUD.UI_HUD_BaseC'
	NumericEditBoxClass=class'UTUINumericEditBox'
	SliderClass=class'UTUISlider'
	EditBoxClass=class'UTUIEditBox'
	CheckBoxClass=class'UTUICollectionCheckBox'
	ComboBoxClass=class'UTUIComboBox'
	OptionButtonClass=class'UTUIOptionButton';
}

