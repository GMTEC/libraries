/*
 Copyright aswing.org, see the LICENCE.txt.
*/
package comp;

import db.DBTranslations;
import flash.events.Event;
import org.aswing.AsWingUtils;
import org.aswing.border.EmptyBorder;
import org.aswing.BorderLayout;
import org.aswing.Component;
import org.aswing.event.FrameEvent;
import org.aswing.FlowLayout;
import org.aswing.geom.IntPoint;
import org.aswing.Icon;
import org.aswing.Insets;
import org.aswing.JFrame;
import org.aswing.JLabel;
import org.aswing.JPanel;
import org.aswing.JTextField;
import org.aswing.SoftBox;

/**
 * JOptionPane makes it easy to pop up a standard dialog box that prompts users 
 * for a value or informs them of something.
 * <p>
 * There's some shortcut to do there with static methods like <code>showMessageDialog</code>, 
 * <code>showInputDialog</code>. But if you want to make a hole control of JOptionPane, 
 * you can create a JOptionPane by yourself and append it into a your JFrame.
 * </p>
 * @see #showMessageDialog()
 * @see #showInputDialog()
 * @author paling
 */
class JOptionPane extends JPanel {
	public var OK_STR:String;
	public var CANCEL_STR:String;
	public var YES_STR:String;
	public var NO_STR:String;
	public var CLOSE_STR:String;

	inline public static var OK:Int= 1; //00001
	inline public static var CANCEL:Int= 2; //00010
	inline public static var YES:Int= 4; //00100
	inline public static var NO:Int= 8; //01000
	inline public static var CLOSE:Int= 16; //10000

	private static var extPanel:JPanel;
	
	private var okButton:JButton1;
	private var cancelButton:JButton1;
	private var yesButton:JButton1;
	private var noButton:JButton1;
	private var closeButton:JButton1;
	
	private var centerPane:JPanel;
	private var msgLabel:JLabel;
	private var inputText:JTextField;
	private var buttonPane:JPanel;
	private var frame:JFrame;


	public function new() {
		super(new BorderLayout());

		OK_STR		=  DBTranslations.getText("IDS_BUT_OK");
		CANCEL_STR	=  DBTranslations.getText("IDS_BUT_CANCEL");
		YES_STR		=  DBTranslations.getText("IDS_YES");
		NO_STR		=  DBTranslations.getText("IDS_NO");
		CLOSE_STR	=  DBTranslations.getText("IDS_BUT_QUIT");
		msgLabel	= new JLabel();
		inputText	= new JTextField();
	}

	public function getFrame():JFrame{
		return frame;
	}
	
	public function getInputText():JTextField{
		return inputText;
	}
	
	public function getMsgLabel():JLabel{
		return msgLabel;
	}
	
	public function getOkButton():JButton1{
		if(okButton == null){
			okButton = new JButton1(OK_STR);
		}
		return okButton;
	}
	
	public function getCancelButton():JButton1{
		if(cancelButton == null){
			cancelButton = new JButton1(CANCEL_STR);
		}
		return cancelButton;
	}

	public function getYesButton():JButton1{
		if(yesButton == null){
			yesButton = new JButton1(YES_STR);
		}
		return yesButton;
	}

	public function getNoButton():JButton1{
		if(noButton == null){
			noButton = new JButton1(NO_STR);
		}
		return noButton;
	}	

	public function getCloseButton():JButton1{
		if(closeButton == null){
			closeButton = new JButton1(CLOSE_STR);
		}
		return closeButton;
	}	
	
	public function addButton(button:JButton1):Void {
			buttonPane.append(button);
	}

	private function setMessage(msg:String):Void{
		msgLabel.setText(msg);
	}

	private function setIcon(icon:Icon):Void{
		msgLabel.setIcon(icon);
	}	

	private function addCloseListener(button:JButton1):Void{
		var f:JFrame = getFrame();
		button.addActionListener(function(?e:Event=null):Void{ f.tryToClose(); });
	}

	/**
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, parentComponent:Component, modal:Boolean, icon:Icon, buttons:Number)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, parentComponent:Component, modal:Boolean, icon:Icon)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, parentComponent:Component, modal:Boolean)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, parentComponent:Component)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function)
	 * <p>
	 * Show a message box with specifield title, message, and icon.
	 * <p>
	 * for example:
	 * <pre>
	 * var handler:Function = __whenUserConformed;
	 * var pane:JOptionPane = showMessageDialog("title", "is that OK?", handler, null, JOptionPane.YES|JOptionPane.NO);
	 * </pre>
	 * will show a message box with yes and no buttons.
	 * 
	 * @param title the title of the box, can be null
	 * @param msg the message , can be null
	 * @param finishHandler the function(result:Number) to call when user finished input, 
	 * will pass a number as parammeter, its value indicate what user's selection. 
	 * For example CANCEL indicate that user pressed CANCEL button, CLOSE indicate that 
	 * user pressed CLOSE button or just closed the frame by click frame's close button, 
	 * YES indicate that user pressed the YES button etc.
	 * @param parentComponent determines the Frame in which the
	 *		dialog is displayed; can be null
	 * @param modal is the window modal, default is true
	 * @param icon the icon, can be null
	 * @param buttons which buttons need to show.
	 * @param closeBox is close the box frame when user click buttons
	 * @see #OK
	 * @see #CANCEL
	 * @see #YES
	 * @see #NO
	 * @see #CLOSE
	 */
	public static function showMessageDialog(title:String, msg:String, finishHandler:Dynamic -> Void=null, parentComponent:Component=null, modal:Bool=true, icon:Icon=null, buttons:Int=OK):JOptionPane{
		var frame:JFrame = new JFrame(AsWingUtils.getOwnerAncestor(parentComponent), title, modal);
		var pane:JOptionPane = new JOptionPane();
		pane.setMessageDialog();
		pane.setMessage(msg);
		pane.setIcon(icon);
		pane.frame = frame;
		var handler:Dynamic -> Void= finishHandler;
		if((buttons & OK) == OK){
			pane.addButton(pane.getOkButton());
			pane.addCloseListener(pane.getOkButton());
			pane.getOkButton().addActionListener(function(?e:Event=null):Void{
				if (handler != null) handler(JOptionPane.OK);
			});
		}
		if((buttons & YES) == YES){
			pane.addButton(pane.getYesButton());
			pane.addCloseListener(pane.getYesButton());
			pane.getYesButton().addActionListener(function(?e:Event=null):Void{
				if (handler != null) handler(JOptionPane.YES);
			});
		}
		if((buttons & NO) == NO){
			pane.addButton(pane.getNoButton());
			pane.addCloseListener(pane.getNoButton());
			pane.getNoButton().addActionListener(function(?e:Event=null):Void{
				if (handler != null) handler(JOptionPane.NO);
			});
		}
		if((buttons & CANCEL) == CANCEL){
			pane.addButton(pane.getCancelButton());
			pane.addCloseListener(pane.getCancelButton());
			pane.getCancelButton().addActionListener(function(?e:Event=null):Void{
				if (handler != null) handler(JOptionPane.CANCEL);
			});
		}
		if((buttons & CLOSE) == CLOSE){
			pane.addButton(pane.getCloseButton());
			pane.addCloseListener(pane.getCloseButton());
			pane.getCloseButton().addActionListener(function(?e:Event=null):Void{
				if (handler != null) handler(JOptionPane.CLOSE);
			});
		}
		frame.addEventListener(FrameEvent.FRAME_CLOSING, 
			function(?e:Event=null):Void{
				if (handler != null) handler(JOptionPane.CLOSE);
			});

		frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		frame.setResizable(false);
		frame.getContentPane().append(pane, BorderLayout.CENTER);
		frame.pack();

		var location:IntPoint = AsWingUtils.getScreenCenterPosition();
		location.x = Math.round(location.x - frame.getWidth()/2);
		location.y = Math.round(location.y - frame.getHeight()/2);

		frame.setLocation(location);
		frame.scaleX = frame.scaleY = 1.4;
		frame.show();
		//Fading.fadeIn(frame, 1, 1);

		return pane;
	}

	public function setMessageDialog() 
	{
		if(centerPane == null)
			centerPane = SoftBox.createVerticalBox(8);

		centerPane.append(AsWingUtils.createPaneToHold(msgLabel, new FlowLayout(FlowLayout.CENTER, 5, 28)));
		setCommonDialog();
		getInputText().setVisible(false);
		msgLabel.setPreferredWidth(600);
		setPreferredHeight(160);		
	}

	public function setInputDialog() 
	{
		if(centerPane == null)
			centerPane = SoftBox.createVerticalBox(8);

			centerPane.append(AsWingUtils.createPaneToHold(msgLabel, new FlowLayout(FlowLayout.CENTER, 5, 10)));
		setCommonDialog();
		msgLabel.setPreferredWidth(240);
		setPreferredHeight(160);
		//inputText.makeFocus();
	}

	function setCommonDialog():Void 
	{
		var inputContainer:JPanel = new JPanel(new BorderLayout());
		inputContainer.setBorder(new EmptyBorder(null, new Insets(0, 8, 0, 8)));

		if (JOptionPane.extPanel != null)
			inputContainer.append(JOptionPane.extPanel, BorderLayout.CENTER);
		else
			inputContainer.append(inputText, BorderLayout.CENTER);

		centerPane.append(inputContainer);
		buttonPane = new JPanel(new FlowLayout(FlowLayout.CENTER));

		msgLabel.setPreferredHeight(28);

		inputText.setPreferredWidth(200);
		inputText.setPreferredHeight(28);

		centerPane.setPreferredWidth(320);
		centerPane.setPreferredHeight(40);

		append(centerPane, BorderLayout.CENTER);
		append(buttonPane, BorderLayout.SOUTH);
	}
	/**
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, defaultValue:String, parentComponent:Component, modal:Boolean, icon:Icon)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, defaultValue:String, parentComponent:Component, modal:Boolean)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, defaultValue:String, parentComponent:Component)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function, defaultValue:String)<br>
	 * showMessageDialog(title:String, msg:String, finishHandler:Function)
	 * <p>
	 * Show a message box with specifield title, message, and icon and a TextField to requare 
	 * user to input a string.
	 * <p>
	 * for example:
	 * <pre>
	 * var handler:Function = __whenUserEntered;
	 * var pane:JOptionPane = showMessageDialog("title", "Please enter your name:", handler, "yournamehere");
	 * </pre>
	 * will show a message box with OK and CANCEL and a input Texts.
	 * 
	 * @param title the title of the box, can be null
	 * @param msg the message , can be null
	 * @param finishHandler the function(result:String) to call when user finished input, 
	 * will pass a string as parammeter, if it is null indicate that user had pressed 
	 * cancel or just closed the frame, otherwise it is the string what user entered.
	 * @param defaultValue the default value for the input
	 * @param parentComponent determines the Frame in which the
			dialog is displayed; can be null
	 * @param modal is the window modal, default is true
	 * @param icon the icon, can be null
	 */
	public static function showInputDialog(title:String, msg:String, finishHandler:Dynamic -> Void=null, defaultValue:String="", parentComponent:Component=null, modal:Bool=true, icon:Icon=null):JOptionPane{
		var frame:JFrame = new JFrame(AsWingUtils.getOwnerAncestor(parentComponent), title, true);
		var pane:JOptionPane = new JOptionPane();

		pane.setInputDialog();

		if(defaultValue != ""){
			pane.inputText.setText(defaultValue);
		}
		pane.setMessage(msg);
		pane.setIcon(icon);
		pane.frame = frame;

		pane.addButton(pane.getOkButton());
		pane.addCloseListener(pane.getOkButton());
		pane.addButton(pane.getCancelButton());
		pane.addCloseListener(pane.getCancelButton());

		var handler:Dynamic -> Void= finishHandler;

		pane.getOkButton().addActionListener(
			function(?e:Event=null):Void{
				if (handler != null) handler(pane.getInputText().getText());
			}
		);

		var cancelHandler:Dynamic -> Void= function(?e:Event=null):Void{
			if (handler != null) handler(null);
		};

		pane.getCancelButton().addActionListener(cancelHandler);
		frame.addEventListener(FrameEvent.FRAME_CLOSING, cancelHandler);

		frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		frame.setResizable(false);
		frame.getContentPane().append(pane, BorderLayout.CENTER);
		frame.pack();
		var location:IntPoint = AsWingUtils.getScreenCenterPosition();
//
		location.x = Math.round(location.x - frame.getWidth()/2);
		location.y = Math.round(location.y - frame.getHeight()/2);
		frame.setLocation(location);
		frame.scaleX = frame.scaleY = 1.4;

		frame.show();
		//Fading.fadeIn(frame, 1, 1);

		return pane;
	}

	/**
	 * 
	 * @param	paneCenter
	 * @param	title
	 * @param	msg
	 * @param	finishHandler
	 * @param	defaultValue
	 * @param	parentComponent
	 * @param	modal
	 * @param	icon
	 * @return
	 */
	public static function showInputDialogWithPanel(paneCenter:JPanel, title:String, msg:String, finishHandler:Dynamic -> Void = null, defaultValue:String = "", parentComponent:Component = null, modal:Bool = true, icon:Icon = null):JOptionPane
	{
		JOptionPane.extPanel = paneCenter;
		return showInputDialog(title, msg, finishHandler, defaultValue, parentComponent, modal, icon);
	}
}