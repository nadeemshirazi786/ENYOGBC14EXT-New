//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// PageExtension EN WMS Item (ID 14229206) extends Record Item Card.
/// </summary>
pageextension 14229224 "WMS Put-away Subform ELA" extends "Whse. Put-away Subform"
{
    layout
    {
        addafter("Qty. to Handle")
        {
            field("Assigned Role"; "Assigned App. Role ELA")
            {
                ApplicationArea = All;
            }

            field("Assigned To"; "Assigned App. User ELA")
            {
                ApplicationArea = All;
            }

            field("Container No."; "Container No. ELA")
            {
                ApplicationArea = All;
            }

            field("Licnese Plate No."; "Licnese Plate No. ELA")
            {
                ApplicationArea = All;
            }

            field(Prioritized; "Prioritized ELA") { }

            field("Received By"; "Received By ELA")
            {
                ApplicationArea = All;
            }

            field("Received Date"; "Received Date ELA")
            {
                ApplicationArea = All;
            }

            field("Received Time"; "Received Time ELA")
            {
                ApplicationArea = All;
            }
        }
    }
}
