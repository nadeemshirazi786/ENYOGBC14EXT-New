pageextension 14229621 "EN LT ItemCard EXT ELA" extends "Item Card"
{
    layout
    {
        addlast("Item Tracking")
        {
            field("Lot No. Assignment Method"; "Lot No. Assignment Method ELA")
            {

            }

        }
        addafter("Base Unit of Measure")
        {

            field("Reporting UOM"; "Reporting UOM ELA")
            {
                ApplicationArea = All;

            }
        }
        addafter("Item Category Code")
        {

            field("Brand Code"; "Brand Code ELA")
            {
                ApplicationArea = All;

            }
            field("Block From Purchase Documents"; "Block From Purch Doc ELA")
            {
                ApplicationArea = All;

            }
            field("Size Code"; "Size Code ELA")
            {
                ApplicationArea = All;
                Lookup = true;

            }
            field("Size Description"; "Size Description ELA")
            {
                ApplicationArea = All;

            }
            field("Qty. on Hand (Rep. UOM)"; "Qty. on Hand (Rep. UOM) ELA")
            {
                ApplicationArea = All;
            }
            field("Qty. on Purch. Ord. (Rep. UOM)"; TransfToRepUOMValue("Qty. on Purch. Order"))
            {
                Caption = 'Qty. on Purch. Ord. (Rep. UOM)';
                ApplicationArea = All;
            }
            field("Qty. on Sales Ord. (Rep. UOM)"; TransfToRepUOMValue("Qty. on Sales Order"))
            {
                Caption = 'Qty. on Sales Ord. (Rep. UOM)';
                ApplicationArea = All;
            }
        }
        addafter("Sales Unit of Measure")
        {
            field("Sales Price Unit of Measure"; Rec."Sales Price UOM ELA")
            {
                ApplicationArea = All;

            }
        }
        moveafter(Description; "Base Unit of Measure")
        moveafter("Reporting UOM"; "Item Category Code")
        moveafter("Brand Code"; Blocked)
        moveafter("Qty. on Hand (Rep. UOM)"; "Qty. on Purch. Order")
        moveafter("Qty. on Purch. Ord. (Rep. UOM)"; "Qty. on Sales Order")
        modify(Type)
        {
            Visible = false;
        }
        modify("Last Date Modified")
        {
            Visible = false;
        }
        modify(GTIN)
        {
            Visible = false;
        }
        addlast(Item)
        {
            field("Bottle Deposit - Sales"; "Bottle Deposit - Sales")
            {
                ApplicationArea = All;
            }
            field("Bottle Deposit - Purchase"; "Bottle Deposit - Purchase")
            {
                ApplicationArea = All;
            }
        }
        addafter("Item Tracking")
        {
            group("Global Group ELA")
            {
                Caption = 'Global Group';
                field("Global Group 1 Code ELA"; "Global Group 1 Code ELA")
                {
                    Caption = 'Override Price';
                }
                field("Global Group 2 Code ELA"; "Global Group 2 Code ELA")
                {
                    Caption = 'Global Group 2 Code';
                }
                field("Global Group 3 Code ELA"; "Global Group 3 Code ELA")
                {
                    Caption = 'Global Group 3 Code';
                }
                field("Global Group 4 Code ELA"; "Global Group 4 Code ELA")
                {
                    Caption = 'Ad 1 Code';
                }
                field("Global Group 5 Code ELA"; "Global Group 5 Code ELA")
                {
                    Caption = 'Ad 2 Code';
                }

            }

        }
        addlast(Purchase)
        {
            field("Receiving Unit of Measure ELA"; "Receiving Unit of Measure ELA")
            {
                Caption = 'Receiving Unit Of Measure';
            }
        }
    }
    actions
    {
        addlast(ItemActionGroup)
        {
            // action("User-Defined Fields")
            // {
            //     ApplicationArea = All;
            //     Image = TaskPage;
            //     RunObject = page "User-Def. Fields - Item ELA";
            //     RunPageLink = "Item No." = field("No.");
            //     trigger OnAction()
            //     begin

            //     end;
            // }
            action("Item Master")
            {
                ApplicationArea = All;
                Image = TaskPage;
                trigger OnAction()
                var
                    recBottleSetup: Record "Bottle Deposit Setup";
                    pBottleSetup: Page "Bottle Deposit Setup ELA";
                begin
                    IF ("Bottle Deposit - Sales" = true) OR ("Bottle Deposit - Purchase" = true) then begin
                        recBottleSetup.Reset();
                        recBottleSetup.SetRange("Item No.", "No.");
                        if recBottleSetup.FindSet() then begin
                            pBottleSetup.SetTableView(recBottleSetup);
                            Page.Run(Page::"Bottle Deposit Setup ELA", recBottleSetup);
                        end else begin
                            Clear(recBottleSetup);
                            recBottleSetup.Init();
                            recBottleSetup."Item No." := "No.";
                            recBottleSetup.Insert(true);
                            recBottleSetup.SetRange("Item No.", "No.");
                            pBottleSetup.SetTableView(recBottleSetup);
                            Page.Run(Page::"Bottle Deposit Setup ELA", recBottleSetup);
                        end;
                    end;
                end;
            }
        }
    }

}


