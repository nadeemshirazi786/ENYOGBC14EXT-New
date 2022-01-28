//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// PageExtension EN Warehouse Shipment (ID 14229230) extends Record Whse. Shipment Subform.
/// </summary>
pageextension 14229230 "Whse. Shipment Subform ELA" extends "Whse. Shipment Subform"
{
    layout
    {
        addafter("Qty. to Ship")
        {
            field("Ship Action"; "Ship Action ELA")
            {
                ApplicationArea = All;
            }
        }

        addafter("Qty. Picked (Base)")
        {
            field("Assigned Role"; Rec."Assigned App. Role ELA")
            {
                ApplicationArea = All;
            }

            field("Assigned To"; "Assigned To ELA")
            {
                ApplicationArea = All;
            }
            field("Release to QC ELA"; "Release to QC ELA")
            {
                Caption = 'Release to QC';
                Editable = false;
            }
            field("Assigned QC User"; "Assigned QC User ELA")
            {
                Caption = 'Assigned QC User';
            }
            field("QC Completed ELA"; "QC Completed ELA")
            {
                Caption = 'QC Completed';
                Editable = false;
            }

        }
    }

    actions
    {
        addlast(Processing)
        {
            action("Remove from Trip")
            {
                ApplicationArea = All;
                Image = DeleteRow;
                trigger OnAction()
                begin
                    TripLoadMgmt.RemoveOrderFromShipment("Source Document", "Source No.", "Trip No. ELA");
                end;
            }

            action("Release to QC")
            {
                caption = 'Release to QC';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    ShipDashBrd: record "Shipment Dashboard ELA";
                    ShipmentMgmt: Codeunit "Shipment Mgmt. ELA";
                    AssignedQCUser: Report "Assigned QC User ELA";
                    AssignedUser: Code[20];
                begin
                    AssignedQCUser.RunModal();
                    IF NOT AssignedQCUser.ExecutedOk(AssignedUser) then
                        Error('');

                    Rec.TestField("Qty. Picked");
                    ShipmentMgmt.WhseShipmentReleaseToQC(Rec."No.", Rec."Line No.", true);
                    ShipmentMgmt.WhseShipmentAssignQCUser(Rec."No.", Rec."Line No.", AssignedUser);

                    CurrPage.Update();
                end;
            }

            action("Reopen For QC ELA")
            {
                caption = 'Reopen For QC';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    ShipDashBrd: record "Shipment Dashboard ELA";
                    ShipmentMgmt: Codeunit "Shipment Mgmt. ELA";
                    AssignedQCUser: Report "Assigned QC User ELA";
                    AssignedUser: Code[20];
                begin

                    ShipmentMgmt.WhseShipmentReleaseToQC(Rec."No.", Rec."Line No.", false);
                    ShipmentMgmt.WhseShipmentAssignQCUser(Rec."No.", Rec."Line No.", '');
                    CurrPage.Update();
                end;
            }
            action("QC Complete")
            {
                caption = 'QC Complete';
                Image = Completed;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    ShipmentMgmt: Codeunit "Shipment Mgmt. ELA";
                begin

                    Rec.TestField("Qty. Picked");
                    ShipmentMgmt.WhseShipmentQCComplete(Rec."No.", Rec."Line No.", true);

                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    var
        ShipmentDashboard: record "Shipment Dashboard ELA";
    begin
        ShipmentDashboard.reset;
        ShipmentDashboard.SetRange("Source No.", "Source No.");
        ShipmentDashboard.SetRange("Source Line No.", "Source Line No.");
        ShipmentDashboard.SetRange("Shipment No.", "No.");
        ShipmentDashboard.SetRange("Shipment Line No.", "Line No.");
        ShipmentDashboard.DeleteAll();
    end;

    var
        TripLoadMgmt: Codeunit "WMS Trip Load Mgmt. ELA";

}
