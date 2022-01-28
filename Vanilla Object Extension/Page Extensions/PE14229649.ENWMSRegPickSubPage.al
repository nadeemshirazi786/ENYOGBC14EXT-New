//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information


/// <summary>
/// PageExtension EN WMS Item (ID 14229206) extends Record Item Card.
/// </summary>
pageextension 14229226 "WMS Reg. Pick Subform ELA" extends "Registered Pick Subform"
{

    //todo #12 @Kamranshehzad handled assigned to / role fields
    layout
    {
        addafter("Unit of Measure Code")
        {

            field("Original Qty."; "Original Qty. ELA")
            {

            }

            field("Trip No."; "Trip No. ELA") { }

            field("Assigned App. Role"; "Assigned App. Role ELA")
            {
            }

            field("Assigned App. User"; "Assigned App. User ELA")
            {

            }

            field("Released On"; "Released On ELA")
            {

            }

            field("Processed Time"; "Processed Time ELA") { }


            field(Prioritized; "Prioritized ELA") { }
            field("Container No."; "Container No. ELA")
            {
                ApplicationArea = All;
            }

            field("Licnese Plate No."; "Licnese Plate No. ELA")
            {
                ApplicationArea = All;
            }


        }
    }


    actions
    {
        addfirst(Processing)
        {
            action("Adjust Quantity")
            {
                ApplicationArea = Suite;
                Caption = '&Adjust Quantity';
                Image = PriceAdjustment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F10';
                ToolTip = 'Adjsut Registered Quantity';
                trigger OnAction()
                var
                    ShipDashbrd: codeunit "Shipment Mgmt. ELA";
                begin
                    ShipDashbrd.AdjustRegPickLinesCosign(Rec, 0, FALSE);
                    CurrPage.Update;
                end;
            }
            group("&Containers")
            {
                action("Show Containers")
                {
                    ApplicationArea = Suite;
                    Caption = '&Containers';
                    Image = ResourceGroup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Shows Items in the container';
                    trigger OnAction()
                    var
                        ContMgmt: Codeunit "Container Mgmt. ELA";
                        WhseDocType: enum "Whse. Doc. Type ELA";
                        SourceDocTypeFilter: enum "WMS Source Doc Type ELA";
                        ENWMSActivityType: Enum "WMS Activity Type ELA";
                    begin
                        // if "Source Type" = 37 then begin
                        // ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', "Location Code", "Source Subtype",
                        //    "Source No.", WhseDocType::Shipment, "Whse. Document No.", ENWMSActivityType::Pick, "No.");
                    end;
                    // end;
                }



                // action("Link Containers")
                // {
                //     ApplicationArea = Suite;
                //     Caption = '&Link Container';
                //     Image = Link;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     PromotedIsBig = true;
                //     ShortCutKey = 'F10';
                //     ToolTip = 'Link Container to the line.';
                //     trigger OnAction()
                //     var
                //         ContMgmt: Codeunit "EN Container Mgmt.";
                //         WhseDocType: enum "EN Whse. Doc. Type";
                //         SourceDocTypeFilter: enum "EN WMS Source Doc Type";
                //     begin
                //         // if "Source Type" = 37 then begin
                //         // ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', "Location Code", "Source Subtype", "Source No.",
                //         //      WhseDocType::Shipment, "Whse. Document No.");
                //         // end;
                //     end;
                // }
            }
        }
    }
}
