//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// PageExtension EN WMS Item (ID 14229206) extends Record Item Card.
/// </summary>
pageextension 14229222 "WMS Activity Hdr. ELA" extends "Warehouse Pick"
{

    //todo #9 @Kamranshehzad add action to show trip
    layout
    {
        addlast(General)
        {

            //todo #10 @Kamranshehzad handle assigned role and assigned to
            field("Assigned Role"; "Assigned App. Role ELA")
            {
            }

            field("Assigned Picker"; "Assigned App. User ELA")
            {
                ToolTip = 'Use this field to assign WMS Picker for entire pick';
            }

            //todo #11 @Kamranshehzad handle ship-tocode /name
            field("Ship-to Code"; "Ship-to Code ELA")
            {
            }

            field("Ship-to Name"; "Ship-to Name ELA")
            {
            }

            field("Trip No."; "Trip No. ELA")
            {
            }
            // field("Release Time"; "Release Time")
            // {
            // }

            field("Created By"; "Created By ELA")
            {
            }

            field("Created On Date Time"; "Created On Date Time ELA")
            {
            }
        }
    }


}
