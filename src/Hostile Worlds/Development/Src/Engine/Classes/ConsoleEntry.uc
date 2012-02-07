/**
 * Temporary widget for representing the region that displays the text currently being typed into the console
 *
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class ConsoleEntry extends UIObject
	native(UIPrivate)
	notplaceable;		// notplaceable until I can resolve the circular docking relationship between the input box and the console prompt label

/** displays the text that is currently being typed */
var					UILabel			ConsolePromptLabel;
var					UIImage			ConsolePromptBackground;
var					UIEditBox		InputBox;
var					UIImage			LowerConsoleBorder;
var					UIImage			UpperConsoleBorder;

/** the current position of the cursor in InputBox's string */
var	transient 		int				CursorPosition;

/** controls whether the underline cursor is rendered */
var()				bool			bRenderCursor;

const ConsolePromptText = "(> ";

cpptext
{
	/**
	 * Initializes the button and creates the background image.
	 *
	 * @param	inOwnerScene	the scene to add this widget to.
	 * @param	inOwner			the container widget that will contain this widget.  Will be NULL if the widget
	 *							is being added to the scene's list of children.
	 */
	virtual void Initialize( UUIScene* inOwnerScene, UUIObject* inOwner=NULL );

	/**
	 * Render this widget.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void Render_Widget( FCanvas* Canvas ) {}	// do nothing

	/**
	 * Perform any additional rendering after this widget's children have been rendered.
	 *
	 * @param	Canvas	the FCanvas to use for rendering this widget
	 */
	virtual void PostRender_Widget( FCanvas* Canvas );
}

event AddedChild( UIScreenObject WidgetOwner, UIObject NewChild )
{
	Super.AddedChild(WidgetOwner, NewChild);
//	if (InputText == None && UILabel(NewChild) != None )
//	{
//		InputText = UILabel(NewChild);
//		InputText.IgnoreMarkup(true);
//		SetValue("");
//	}
//	else if ( InputBox == None && UIEditBox(NewChild) != None )
//	{
//		InputBox = UIEditBox(NewChild);
//		InputBox.IgnoreMarkup(true);
//		SetValue("");
//	}
}

/**
 * Called immediately after a child has been removed from this screen object.  Clears the NotifyPositionChanged delegate in the removed child
 *
 * @param	WidgetOwner		the screen object that the widget was removed from.
 * @param	OldChild		the widget that was removed
 * @param	ExclusionSet	used to indicate that multiple widgets are being removed in one batch; useful for preventing references
 *							between the widgets being removed from being severed.
 *							NOTE: If a value is specified, OldChild will ALWAYS be part of the ExclusionSet, since it is being removed.
 */
event RemovedChild( UIScreenObject WidgetOwner, UIObject OldChild, optional array<UIObject> ExclusionSet )
{
	Super.RemovedChild(WidgetOwner, OldChild, ExclusionSet);
//	if ( InputText == OldChild )
//	{
//		InputText = None;
//	}
//	else if ( InputBox == OldChild )
//	{
//		InputBox = None;
//	}
}

event PostInitialize()
{
	Super.PostInitialize();

	// setup docking links
	SetupDockingLinks();
//	InputText = UILabel(FindChild('InputText'));
//	if ( InputText != None )
//	{
//		InputText.IgnoreMarkup(true);
//		SetValue("");
//	}
//	else
//	{
//		InputBox = UIEditBox(FindChild('InputBox'));
//		if ( InputBox != None )
//		{
//			InputBox.IgnoreMarkup(true);
//			SetValue("");
//		}
//	}
}

function SetupDockingLinks()
{
	// set our own dock targets.
//	SetDockTarget(UIFACE_Top, UpperConsoleBorder, UIFACE_Top);
	SetDockTarget(UIFACE_Bottom, GetScene(), UIFACE_Bottom);

	// set the docktargets for the input box
	InputBox.SetDockTarget(UIFACE_Left, ConsolePromptLabel, UIFACE_Right);
	InputBox.SetDockTarget(UIFACE_Right, Self, UIFACE_Right);
	InputBox.SetDockTarget(UIFACE_Bottom, LowerConsoleBorder, UIFACE_Top);

	// console prompt background
	ConsolePromptBackground.SetDockTarget(UIFACE_Left, ConsolePromptLabel, UIFACE_Left);
	ConsolePromptBackground.SetDockTarget(UIFACE_Top, ConsolePromptLabel, UIFACE_Top);
	ConsolePromptBackground.SetDockTarget(UIFACE_Right, ConsolePromptLabel, UIFACE_Right);
	ConsolePromptBackground.SetDockTarget(UIFACE_Bottom, ConsolePromptLabel, UIFACE_Bottom);

	// console prompt
	ConsolePromptLabel.SetDockTarget(UIFACE_Left, Self, UIFACE_Left);
	ConsolePromptLabel.SetDockTarget(UIFACE_Top, InputBox, UIFACE_Top);
	ConsolePromptLabel.SetDockTarget(UIFACE_Bottom, InputBox, UIFACE_Bottom);

	// border images
	LowerConsoleBorder.SetDockParameters(UIFACE_Top, Self, UIFACE_Bottom, -2.f);
	LowerConsoleBorder.SetDockTarget(UIFACE_Bottom, Self, UIFACE_Bottom);

	UpperConsoleBorder.SetDockParameters(UIFACE_Top, InputBox, UIFACE_Top, -2.f);
	UpperConsoleBorder.SetDockTarget(UIFACE_Bottom, InputBox, UIFACE_Top);
}

function SetValue( string NewValue )
{
	if ( InputBox != None )
	{
		InputBox.SetValue(NewValue);
	}
}

DefaultProperties
{
	WidgetTag=ConsoleEntry
	PrimaryStyle=(DefaultStyleTag="ConsoleStyle")
	bSupportsPrimaryStyle=false
	bRenderCursor=false

	DefaultStates.Add(class'UIState_Focused')

	Begin Object Class=UIEditBox Name=InputBoxTemplate
		WidgetTag=InputBox
		TabIndex=0
		Position=(ScaleType[UIFACE_Top]=EVALPOS_PixelViewport)

//		Begin Object Class=UIComp_DrawStringEditbox Name=InputStringRenderer
//			WrapMode=ADJUST_None
//			bIgnoreMarkup=true
//			StringCaret=(bDisplayCaret=true,CaretWidth=1.5f)
//			StringStyle=(DefaultStyleTag="ConsoleStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
//			AutoSizeParameters(UIORIENT_Vertical)=(Padding=(Value[UIAUTOSIZEREGION_Minimum]=3.f,Value[UIAUTOSIZEREGION_Maximum]=1.f),bAutoSizeEnabled=true)
//		End Object
//		StringRenderComponent=InputStringRenderer
//
//		Begin Object class=UIComp_DrawImage Name=InputBackgroundTemplate
//			ImageStyle=(DefaultStyleTag="ConsoleBufferImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
//			StyleResolverTag="Background Image Style"
//		End Object
//		BackgroundImageComponent=InputBackgroundTemplate
	End Object
	InputBox=InputBoxTemplate

	Begin Object Class=UIImage Name=ConsolePromptBackgroundTemplate
		WidgetTag=ConsoleBackground
		TabIndex=1

//		Begin Object Class=UIComp_DrawImage Name=PromptBackgroundTemplate
//			ImageStyle=(DefaultStyleTag="ConsoleBufferImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
//		End Object
//		ImageComponent=PromptBackgroundTemplate

	End Object
	ConsolePromptBackground=ConsolePromptBackgroundTemplate

	Begin Object Class=UILabel Name=ConsolePromptTemplate
		WidgetTag=ConsolePrompt
		TabIndex=2
		DataSource=(MarkupString="(> ",RequiredFieldType=DATATYPE_Property)
		Position=(Value[UIFACE_Right]=20,ScaleType[UIFACE_Right]=EVALPOS_PixelOwner)

//		Begin Object Class=UIComp_DrawString Name=PromptStringRenderer
//			StringStyle=(DefaultStyleTag="ConsoleStyle",RequiredStyleClass=class'Engine.UIStyle_Combo')
//			bIgnoreMarkup=true
//			AutoSizeParameters(UIORIENT_Horizontal)=(bAutoSizeEnabled=true)
//		End Object
//		StringRenderComponent=PromptStringRenderer
	End Object
	ConsolePromptLabel=ConsolePromptTemplate

	Begin Object Class=UIImage Name=LowerConsoleBorderTemplate
		WidgetTag=LowerConsoleBorder
		TabIndex=3
		Position=(Value[UIFACE_Left]=0,ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,Value[UIFACE_Right]=1,ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner)
//		Begin Object Class=UIComp_DrawImage Name=LowerConsoleImageTemplate
//			ImageStyle=(DefaultStyleTag="ConsoleImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
//		End Object
//		ImageComponent=LowerConsoleImageTemplate

	End Object
	LowerConsoleBorder=LowerConsoleBorderTemplate

	Begin Object Class=UIImage Name=UpperConsoleBorderTemplate
		WidgetTag=UpperConsoleBorder
		TabIndex=4
		Position=(Value[UIFACE_Left]=0,ScaleType[UIFACE_Left]=EVALPOS_PercentageOwner,Value[UIFACE_Right]=1,ScaleType[UIFACE_Right]=EVALPOS_PercentageOwner,Value[UIFACE_Top]=2.f,ScaleType[UIFACE_Top]=EVALPOS_PixelOwner)
		DockTargets=(bLockHeightWhenDocked=true)
//		Begin Object Class=UIComp_DrawImage Name=UpperConsoleImageTemplate
//			ImageStyle=(DefaultStyleTag="ConsoleImageStyle",RequiredStyleClass=class'Engine.UIStyle_Image')
//		End Object
//		ImageComponent=UpperConsoleImageTemplate
	End Object
	UpperConsoleBorder=UpperConsoleBorderTemplate

	Children.Add(InputBoxTemplate)
	Children.Add(ConsolePromptBackgroundTemplate)
	Children.Add(ConsolePromptTemplate)
	Children.Add(LowerConsoleBorderTemplate)
	Children.Add(UpperConsoleBorderTemplate)
}
