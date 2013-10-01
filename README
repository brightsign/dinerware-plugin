Overview
==============
This tech note details how to integrate your digital menu board presentations in BrightAuthor with the Dinerware online database. For more information about creating and publishing presentations, please see the <a href="http://support.brightsign.biz/entries/314526-brightsign-user-guides-troubleshooting">BrightAuthor User Guide</a>.

An example presentation that uses this plugin can be found <a href="ftp://ftp.brightsignnetwork.com/download/dinerware/examples/dinerware-example-1.0.zip">here</a>.

Creating a Set of User Variables
-------------------------------------------
First, you will need to create a number of User Variables in BrightAuthor. These variables will allow you to access the Dinerware database and display menu items, prices, and descriptions. To create User Variables in a presentation, navigate to <strong>File > Presentation Properties > Variables</strong> and click the <strong>Add Variable</strong> button.

The following User Variables need a <strong>Default Value</strong> along with the <strong>Name</strong>:
<ul>
<li><strong>brain_url</strong>: Enter the IP address of the Dinerware host computer.</li>
<li><strong>numPresentationMenuItems<strong>: Enter the total number of menu items displayed in the presentation. This number includes all items, even if some of the items are only displayed at certain times.</li>
</ul>

The following User Variables only need to have a correct <strong>Name</strong>. You can enter any arbitrary value in the <strong>Default Value</strong> field because it will be automatically retrieved from the Dinerware server by the plugin. The “X” in each of these variables represents the menu item number: For example, “ItemX_name” represents “Item1_name”, “Item2_name”, “Item3_name”, and so on.
<ul>
<li><strong>ItemX_name</strong>: The name of the menu item.</li>
<li><strong>ItemX_price</strong>: The price of the menu item.</li>
<li><strong>ItemX_desc</strong>: A description of the menu item.</li>
</ul>

Adding the Dinerware Plugin
-------------------------------------
Next, you need to add the Dinerware plugin to your presentation:
<ol>
<li>Navigate to <strong>File > Presentation Properties > Autorun</strong>.</li>
<li>Click the <strong>Add Script Plugin</strong> button.</li>
<li>Enter “dinerware” in the <strong>Name</strong> field.</li>
<li>Click the <strong>Browse</strong> button. Locate and select the <em>dinerware_plugin.brs/em> file.</li>
</ol>

Adding Items to your Menu Board
--------------------------------------------
You will need to use a Live Text state to display the Dinerware menu items on your digital menu board: 
<ol>
<li>Click the <strong>interactive</strong> option to the right of the playlist to make the presentation interactive.</li>
<li>Select the <strong>other</strong> tab in the <strong>Media Library</strong> section.</li>
<li>Drag and drop the <strong>Live Text</strong> icon onto the playlist area.</li>
<li>Enter a <strong>State name</strong> and specify a <strong>Background Image</strong> for the menu board.</li>
<li>Change the type of the text box to <strong>User Variable</strong> and select a variable for the first menu item.</li>
<li>Click the <strong>Add Item</strong> button to create text boxes for additional items, prices and descriptions.</li>
</ol>

Setting a Refresh Timer
-------------------------------
The Dinerware plugin should regularly refresh the contents of the menu board (i.e. the User Variables). The easiest way to accomplish this is to add a Send UDP command to a Timer event:
<ol>
<li>Select the <strong>events</strong> tab in the <strong>Media Library</strong> section.</li>
<li>Drag and drop the <strong>Timer</strong> event icon onto the Live Text state you created in the previous section.</li>
<li>In the <strong>Specify timeout</strong> field, specify an update interval in seconds. We recommend specifying an update interval of 15 seconds or greater to avoid placing too much strain on your networking infrastructure.</li>
<li>Set the transition to <strong>Remain on current state</strong>.</li>
<li>Select the Advanced tab while in the <strong>Timeout Event</strong> window.</li>
<li>Click the <strong>Add Command</strong> button.</li>
<li>Select the <strong>Send > UDP</strong command. In the <strong>Command Parameters</strong> field, enter “dinerware!getmenu”.</li>
</ol>
<p>You can also set updates to occur upon other interactive events (UDP Input, Keyboard Input, Rectangular Touch, etc.). Simply add the desired event to the Live Text state and follow steps 4-7 above.</p>
