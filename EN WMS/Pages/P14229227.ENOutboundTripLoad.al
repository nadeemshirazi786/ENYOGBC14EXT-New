//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Page EN Trip Load (ID 14229226).
/// </summary>
page 14229227 "Outbound Trip Load ELA"
{

    Caption = 'Outbound Trip Load';
    PageType = Card;
    SourceTable = "Trip Load ELA";
    PromotedActionCategories = 'New,Process,Report,Set Status,Posting,,,,,Navigate';

    layout
    {
        area(content)
        {

            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                }

                field("Load Date"; Rec."Load Date")
                {
                    ApplicationArea = All;
                }

                field(Location; Location)
                {
                    ApplicationArea = All;
                }

                field(Status; Status)
                {
                    ApplicationArea = All;
                }


                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                }
                field("Last modified By"; Rec."Last modified By")
                {
                    ApplicationArea = All;
                }
                field("Last Modified On"; Rec."Last Modified On")
                {
                    ApplicationArea = All;
                }

            }
            group("Truck Information")
            {

                field("Door No."; Rec."Door No.")
                {
                    ApplicationArea = All;
                }
                field("Shipper Name"; Rec."Shipper Name")
                {
                    ApplicationArea = All;
                }
                field("Carrier Name"; Rec."Carrier Name")
                {
                    ApplicationArea = All;
                }

                field("Company owned Truck"; Rec."Company owned Truck")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                    begin
                        if ("Company owned Truck") then
                            IsCompanyOwned := true
                        else
                            IsCompanyOwned := false;
                    end;
                }
                field("Truck Code"; Rec."Truck Code")
                {
                    ApplicationArea = All;
                }

                field("Truck Plate No."; Rec."Truck Plate No.")
                {
                    ApplicationArea = All;
                    Editable = NOT IsCompanyOwned;
                }

                field("Driver Name"; Rec."Driver Name")
                {
                    ApplicationArea = All;
                }


                field("Truck Temperature"; Rec."Truck Temperature")
                {
                    ApplicationArea = All;
                }

                field("No. of Pallets"; Rec."No. of Pallets")
                {
                    ApplicationArea = All;
                }
                field("Total Weight"; Rec."Total Weight")
                {
                    ApplicationArea = All;
                }
                field("Temp Tag No."; Rec."Temp Tag No.")
                {
                    ApplicationArea = All;
                }
                field("Seal No."; Rec."Seal No.")
                {
                    ApplicationArea = All;
                }
                field("Route No."; Rec."Route No.")
                {
                    ApplicationArea = All;
                }
                field("Product Temperature"; Rec."Product Temperature")
                {
                    ApplicationArea = All;
                }
            }
            group("Load Orders")
            {
                part(TripOrders; "OutBnd. Trip Orders SF ELA")
                {
                    ApplicationArea = basic, suite;
                    SubPageLink = "Load No." = field("No."), Direction = field(Direction);
                    UpdatePropagation = both;
                }
            }
        }

    }

    actions
    {
        area(processing)
        {
            group("Posting")
            {
                Caption = 'Post Trip';
                Image = PostDocument;
                action(Post)
                {
                    ApplicationArea = Suite;
                    Caption = '&Post';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';
                    ToolTip = 'Post Load Trip and all the shipments in the trip.';

                    trigger OnAction()
                    var
                    begin
                        PostDocument(Rec);
                    end;
                }
            }

            group("Set Status")
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    // PromotedOnly = true;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the Load Trip to create-update shipments.';

                    trigger OnAction()
                    var
                        ReleaseTripDoc: Codeunit "Release Trip Document ELA";
                    begin
                        ReleaseTripDoc.Run(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Re&open';
                    Enabled = Status <> Status::Open;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category4;
                    // PromotedOnly = true;
                    ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed.';

                    trigger OnAction()
                    var
                        ReleaseTripDoc: Codeunit "Release Trip Document ELA";
                    begin
                        ReleaseTripDoc.ReOpen(Rec);
                    end;
                }

                action(Completed)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'C&ompleted';
                    Enabled = Status <> Status::Completed;
                    Image = Completed;
                    Promoted = true;
                    PromotedCategory = Category4;
                    // PromotedOnly = true;
                    ToolTip = 'Close the trip so that no more loads can be added to it.';

                    trigger OnAction()
                    var
                        ReleaseTripDoc: Codeunit "Release Trip Document ELA";
                    begin
                        ReleaseTripDoc.CloseTrip(Rec);
                    end;
                }


                action(Cancel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cance&l';
                    Enabled = Status <> Status::Cancelled;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;
                    // PromotedOnly = true;
                    ToolTip = 'Cancel the trip. This will work if no order is picked.';

                    trigger OnAction()
                    var
                        ReleaseTripDoc: Codeunit "Release Trip Document ELA";
                    begin
                        ReleaseTripDoc.CloseTrip(Rec);
                    end;
                }

                action(ShowDashboard)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Trip &Dashboard';
                    Image = Documents;
                    Promoted = true;
                    PromotedCategory = Process;
                    // PromotedOnly = true;
                    ToolTip = 'Shows trip orders on shipment dashboard';

                    trigger OnAction()
                    var
                        ShipmentDashbrdP: page "Shipment Management ELA";
                        ShipmentDashbrd: record "Shipment Dashboard ELA";
                    begin
                        ShipmentDashbrd.Reset();
                        ShipmentDashbrd.SetFilter("Trip No.", '%1', "No.");
                        ShipmentDashbrdP.SetTableView(ShipmentDashbrd);
                        ShipmentDashbrdP.run;
                    end;
                }

                action("Containers")
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
                        ContMgmt.ShowTripContainers("No.");
                        /*ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', Location, "Source Subtype",
                            "Source No.", WhseDocType::Shipment, "Whse. Document No.", ENWMSActivityType::Pick, "No.");*/
                    end;
                }

            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
    begin
        Direction := Direction::Outbound;
    end;

    local procedure PostDocument(Rec: Record "Trip Load ELA")
    var

    begin
        COdeunit.Run(CODEUNIT::"Trip Post Document ELA");
    end;

    var
        IsCompanyOwned: Boolean;
}
