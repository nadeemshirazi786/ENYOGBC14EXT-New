pageextension 14229641 "Whse Pick Subform ELA" extends "Whse. Pick Subform"
{
    layout
    {
        modify("Qty. to Handle")
        {
            trigger OnAfterValidate()
            var
                WMSServices: Codeunit "WMS Activity Mgmt. ELA";
            begin
                WMSServices.UpdateTakePlaceLine(FIELDNO("Qty. to Handle"), Rec);
                CurrPage.Update();
            end;
        }
		addafter("Qty. to Handle")
        {
            field("No."; "No.")
            {
                ApplicationArea = All;
            }
            field("Line No"; "Line No.")
            {
                ApplicationArea = All;
            }
            field("Activity Type"; "Activity Type")
            {
                ApplicationArea = All;
            }
            field("Assigned Role"; "Assigned App. Role ELA")
            {
                ApplicationArea = All;
            }

            field("Assigned Picker"; "Assigned App. User ELA")
            {
                ApplicationArea = All;
            }

            field("Original Qty."; "Original Qty. ELA")
            {
                ApplicationArea = All;
            }

            field("Released To Pick"; "Released To Pick ELA")
            {
                ApplicationArea = All;
            }

            field("Released At"; "Released At ELA")
            {
                ApplicationArea = All;
            }

            field(Prioritized; "Prioritized ELA")
            {
                ApplicationArea = All;
            }

            field("Trip No."; "Trip No. ELA")
            {
                ApplicationArea = All;
            }

            field("Ship Action"; "Ship Action ELA")
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
        }
    }

    actions
    {
        addfirst(Processing)
        {
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
                        if "Source Type" = 37 then begin
                            ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', "Location Code", "Source Subtype",
                            "Source No.", WhseDocType::Shipment, "Whse. Document No.", ENWMSActivityType::Pick, "No.");
                        end;
                    end;
                }

                action("Link Containers")
                {
                    ApplicationArea = Suite;
                    Caption = '&Link Container';
                    Image = Link;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F10';
                    ToolTip = 'Link Container to the line.';
                    trigger OnAction()
                    var
                        ContMgmt: Codeunit "Container Mgmt. ELA";
                        WhseDocType: enum "Whse. Doc. Type ELA";
                        SourceDocTypeFilter: enum "WMS Source Doc Type ELA";
                        LinkCont: Page "Link Container Card ELA";
                        ENWMSActivityType: Enum "WMS Activity Type ELA";
                    begin
                        LinkCont.SetWhseActLine(Rec);
                        LinkCont.RunModal();
                        CurrPage.Update();
                        if "Source Type" = 37 then begin
                            ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', "Location Code", "Source Subtype",
                           "Source No.", WhseDocType::Shipment, "Whse. Document No.", ENWMSActivityType::Pick, "No.");
                        end;
                    end;
                }

                action("New Container")
                {
                    ApplicationArea = Suite;
                    Caption = '&New Container';
                    Image = New;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F11';
                    ToolTip = 'New Container for the line.';
                    trigger OnAction()
                    var
                        ContMgmt: Codeunit "Container Mgmt. ELA";
                        containerNo: code[20];
                    begin
                        containerNo := ContMgmt.CreateNewContainer('', Rec."Location Code", false);
                        ContMgmt.AddContentToContainer(ContainerNo, Rec."Item No.", Rec."Unit of Measure Code", Rec.Quantity
                      , Rec."Lot No.", Rec."Source No.", Rec."Source Line No.", Rec."Whse. Document Type", Rec."Whse. Document No.",
                      Rec."Activity Type", Rec."No.", Rec."Line No.");

                        Message('Container %1 has been assigned successfully.', ContainerNo);
                        CurrPage.Update();
                        /* if "Source Type" = 37 then begin
                             ContMgmt.ShowContainer(SourceDocTypeFilter::"Sales Order", '', "Location Code", "Source Subtype", "Source No.",
                                  WhseDocType::Shipment, "Whse. Document No.");
                         end;*/
                    end;
                }

                action("View Container")
                {
                    ApplicationArea = Suite;
                    Caption = 'View Container';
                    image = View;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortcutKey = 'F2';
                    ToolTip = 'View Container';
                    trigger OnAction()
                    var
                        Container: record "Container ELA";
                        ContainerCard: page "Container Card ELA";
                    begin
                        if Container.Get(Rec."Container No. ELA") then begin
                            ContainerCard.SetRecord(Container);
                            ContainerCard.Run();
                        end;


                    end;
                }
            }
        }
    }

    var
        myInt: Integer;
}