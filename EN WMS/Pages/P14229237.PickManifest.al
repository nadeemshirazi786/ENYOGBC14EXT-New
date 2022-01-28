page 14229237 "Pick Manifest ELA"
{
    Caption = 'Pick Manifest';
    DeleteAllowed = false;
    PageType = List;
    ApplicationArea = All;
    ShowFilter = False;
    UsageCategory = Administration;
    Editable = false;
    InsertAllowed = False;
    ModifyAllowed = False;
    SourceTable = "Registered Whse. Activity Line";

    layout
    {
        area(Content)
        {
            /*  group(Group)
              {
                  Caption = 'Filters';
                  field(DateFilter; ShipDateFilter)
                  {
                      Caption = 'Date Filter';
                      ApplicationArea = All;
                  }
                  field(OrderNoFilter; OrderNoFilter)
                  {
                      Caption = 'Order No. Filter';
                  }
                  field(ItemNoFilter; ItemNoFilter)
                  {
                      Caption = 'Item No. Filter';
                  }
                  field(LocationFilter; LocationFilter)
                  {
                      Caption = 'Location Filter';
                      DrillDown = true;
                      Lookup = true;
                      TableRelation = Location.Code;
                  }
                  field(TripIDFilter; TripIDFilter)
                  {

                      Caption = 'Trip No. Filter';
                      DrillDown = true;
                      Lookup = true;
                      TableRelation = "Trip Load ELA"."No." where(Direction = const(Outbound));
                      //where(Status = Filter(Status::Open | Status::"In Progress"));
                      trigger OnValidate()
                      begin
                          //  PopulateData;
                      end;
                  }
                  field(RegisteredPickNo; RegisteredPickNo)
                  {
                      Caption = 'Pick No. Filter';
                  }

              }*/
            repeater(Group1)
            {
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = ALL;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = ALL;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = ALL;
                }
                field(Description; Description)
                {

                }
                field(Quantity; Quantity)
                {

                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {

                }
                field("Original Qty. ELA"; "Original Qty. ELA")
                {

                }
                field("Reason Code ELA"; "Reason Code ELA")
                {
                    ApplicationArea = All;
                }
                field("Assigned App. Role ELA"; "Assigned App. Role ELA")
                {

                }
                field("Assigned App. User ELA"; "Assigned App. User ELA")
                {

                }
                field("Released On ELA"; "Released On ELA")
                {

                }
                field("Processed Time ELA"; "Processed Time ELA")
                {

                }
                field("Container No. ELA"; "Container No. ELA")
                {

                }
                field("Licnese Plate No. ELA"; "Licnese Plate No. ELA")
                {

                }

            }
        }
    }
    actions
    {
        area(Reporting)
        {
            group("Actions")
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
                action("Warehouse Shipment")
                {
                    Caption = 'Warehouse shipment';
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        // WhseItemSummay: Report "WMS Item Summary";
                        WhseShipment: report "Whse. - Shipment";
                        TmpWhseShipHdr: Record "Warehouse Shipment Header" temporary;
                        ShipmentFilter: Text[1024];
                        WhseShpHdr: Record "Warehouse Shipment Header";
                        DeliverManifest: Report "Delivery Manifest Ticket";
                    begin
                        IF rec.FindSet() then begin
                            repeat
                                if not TmpWhseShipHdr.Get(rec."Whse. Document No.") then begin
                                    TmpWhseShipHdr.Init;
                                    TmpWhseShipHdr."No." := rec."Whse. Document No.";
                                    TmpWhseShipHdr.Insert;
                                    IF ShipmentFilter = '' then
                                        ShipmentFilter := rec."Whse. Document No."
                                    Else
                                        ShipmentFilter := ShipmentFilter + '|' + Rec."Whse. Document No.";
                                end;
                            until rec.Next = 0;
                        end;
                        WhseShpHdr.Reset();
                        WhseShpHdr.SetFilter("No.", ShipmentFilter);
                        IF WhseShpHdr.FindSet() THEN begin
                            Clear(WhseShipment);
                            WhseShipment.UseRequestPage(false);
                            WhseShipment.SetTableView(WhseShpHdr);
                            WhseShipment.Run();
                        end;
                        //Location Code,Bin Code,Item No.,Variant Code,Unit of Measure Code
                        // Clear(WhseItemSummay);
                        // //IF "Item No." <> '' THEN
                        // WhseItemSummay.SetItem("Item No.", 'WH148');
                        // WhseItemSummay.RunModal;
                        // Clear(WhseItemSummay);
                    end;
                }

                action("Registered Pick Manifest")
                {
                    Caption = 'Registered Pick Manifest';
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        // WhseItemSummay: Report "WMS Item Summary";
                        RegisteredDoc: Report "Registered Pick Document ELA";
                        RegisteredPick: Record "Registered Whse. Activity Hdr.";
                    begin
                        IF RegisteredPick.Get(rec."Activity Type"::Pick, rec."No.") Then begin
                            Clear(RegisteredDoc);
                            RegisteredDoc.UseRequestPage(false);
                            //RegisteredDoc.SetTableView(RegisteredPick);
                            //Message(RegisteredPick."No.");
                            RegisteredDoc.SetRegisteredPickNo(RegisteredPick."No.");
                            RegisteredDoc.Run();
                        end;


                        //Location Code,Bin Code,Item No.,Variant Code,Unit of Measure Code
                        // Clear(WhseItemSummay);
                        // //IF "Item No." <> '' THEN
                        // WhseItemSummay.SetItem("Item No.", 'WH148');
                        // WhseItemSummay.RunModal;
                        // Clear(WhseItemSummay);
                    end;
                }
            }
        }
    }

    var
        TripIDFilter: code[250];
        ShipDateFilter: Text[30];
        OrderNoFilter: Code[250];
        ItemNoFilter: Code[20];
        LocationFilter: Code[20];
        RegisteredPickNo: code[20];

}