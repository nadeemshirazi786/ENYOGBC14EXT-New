page 14228832 "YOG Item List"
{
    Editable = false;
    Caption = 'Item List';
    SourceTable = Item;
    UsageCategory = Lists;
    PageType = List;
    CardPageID = "Item Card";
    layout
    {
        area(Content)
        {
            repeater(group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Inventory; Inventory)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Qty. on Hand (Rep. UOM)"; "Qty. on Hand (Rep. UOM) ELA")
                {
                    ApplicationArea = All;
                    Caption = 'YOG Qty. on Hand (Rep. UOM)';
                }
                field("Qty. on Purch. Order"; "Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. on Sales Order"; "Qty. on Sales Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. in Transit"; "Qty. in Transit")
                {
                    ApplicationArea = All;
                }
                field("Trans. Ord. Receipt (Qty.)"; "Trans. Ord. Receipt (Qty.)")
                {
                    ApplicationArea = All;
                }
                field("Trans. Ord. Shipment (Qty.)"; "Trans. Ord. Shipment (Qty.)")
                {
                    ApplicationArea = All;
                }
                field("Created From Nonstock Item"; "Created From Nonstock Item")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Substitutes Exist"; "Substitutes Exist")
                {
                    ApplicationArea = All;
                }
                field("Stockkeeping Unit Exists"; "Stockkeeping Unit Exists")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Assembly BOM"; "Assembly BOM")
                {
                    ApplicationArea = All;
                }
                field("Production BOM No."; "Production BOM No.")
                {
                    ApplicationArea = All;
                }
                field("Routing No."; "Routing No.")
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; "Base Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Shelf No."; "Shelf No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Costing Method"; "Costing Method")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Cost is Adjusted"; "Cost is Adjusted")
                {
                    ApplicationArea = All;
                }
                field("Standard Cost"; "Standard Cost")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Last Direct Cost"; "Last Direct Cost")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Price/Profit Calculation"; "Price/Profit Calculation")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Profit %"; "Profit %")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Inventory Posting Group"; "Inventory Posting Group")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; "VAT Prod. Posting Group")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Item Disc. Group"; "Item Disc. Group")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Critical; Critical)
                {
                    ApplicationArea = All;
                }
                field("Tariff No."; "Tariff No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Search Description"; "Search Description")
                {
                    ApplicationArea = All;
                }
                field("Size Code"; "Size Code ELA")
                {
                    ApplicationArea = All;
                    Caption = 'Size Code';
                }
                field("Overhead Rate"; "Overhead Rate")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Indirect Cost %"; "Indirect Cost %")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Item Status"; "Item Status ELA")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Item Category Code"; "Item Category Code")
                {
                    ApplicationArea = All;
                }
                field("Brand Code"; "Brand Code ELA")
                {
                    ApplicationArea = All;
                    Caption = 'Brand Code';
                }
                field(Blocked; Blocked)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Phys Invt Counting Period Code"; "Phys Invt Counting Period Code")
                {
                    ApplicationArea = All;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Sales Unit of Measure"; "Sales Unit of Measure")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Sales Price UOM"; "Sales Price UOM ELA")
                {
                    Visible = false;
                    ApplicationArea = All;
                    Caption = 'Sales Price Unit of Measure';
                }
                field("Replenishment System"; "Replenishment System")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Purch. Unit of Measure"; "Purch. Unit of Measure")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Lead Time Calculation"; "Lead Time Calculation")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Manufacturing Policy"; "Manufacturing Policy")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Flushing Method"; "Flushing Method")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Reporting UOM ELA"; "Reporting UOM ELA")
                {
                    ApplicationArea = All;
                    Caption = 'YOG Reporting UOM';
                }
                field("Assembly Policy"; "Assembly Policy")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Item Tracking Code"; "Item Tracking Code")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Global Group 1 Code"; "Global Group 1 Code ELA")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Global Group 2 Code"; "Global Group 2 Code ELA")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Global Group 3 Code"; "Global Group 3 Code ELA")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Global Group 4 Code"; "Global Group 4 Code ELA")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Global Group 5 Code"; "Global Group 5 Code ELA")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Special; gtxtSpecial)
                {
                    ApplicationArea = All;
                }
            }
            part("ItemAvailMatrixSubPage"; "Item Avail. by Loc Subpage ELA")
            {
                Editable = false;
            }
        }
        area(FactBoxes)
        {
            part("Standard Prices"; "Standard Price Factbox ELA")
            {

            }
            part("Sales Prices"; "Sales Price FactBox ELA")
            {

            }
            part("Combination Deals"; "Combination Deal Factbox ELA")
            {
                SubPageLink = "No." = FIELD("No.");
            }
            part("Item Invoicing FactBox"; "Item Invoicing FactBox")
            {
                Caption = 'Item Details - Invoicing';
                Visible = true;
                SubPageLink = "No." = FIELD("No."), "Date Filter" = FIELD("Date Filter"), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Bin Filter" = FIELD("Bin Filter"), "Variant Filter" = FIELD("Variant Filter"), "Lot No. Filter" = FIELD("Lot No. Filter"), "Serial No. Filter" = FIELD("Serial No. Filter");
            }
            part("Item Planning FactBox"; "Item Planning FactBox")
            {
                Caption = 'Item Details - Planning';
                Visible = true;
                SubPageLink = "No." = FIELD("No."), "Date Filter" = FIELD("Date Filter"), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Bin Filter" = FIELD("Bin Filter"), "Variant Filter" = FIELD("Variant Filter"), "Lot No. Filter" = FIELD("Lot No. Filter"), "Serial No. Filter" = FIELD("Serial No. Filter");
            }
            systempart(Links; Links)
            {
                Visible = true;
            }
            systempart(Note; Notes)
            {
                Visible = true;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Item Price")
            {
                ApplicationArea = All;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "EN Price List Line";
                RunPageView = SORTING(Type, Code, "Sales Type", "Sales Code", "Starting Date", "Variant Code", "Unit of Measure Code", "Minimum Quantity");
                RunPageLink = Type = CONST(Item), Code = FIELD("No.");
            }
            action("Ledger E&ntries")
            {
                ApplicationArea = All;
                Image = ItemLedger;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Item Ledger Entries";
                RunPageView = SORTING("Item No.");
                RunPageLink = "Item No." = FIELD("No.");
            }
            action("Item Journal")
            {
                ApplicationArea = All;
                Image = Journals;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Item Journal";
            }
            action("Adjust Item Cost/Price")
            {
                ApplicationArea = All;
                Image = AdjustItemCost;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = report "Adjust Item Costs/Prices";
            }
            action("Inventory Valuation")
            {
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                RunObject = report "Inventory Valuation";
            }
            action("Inventory to G/L Reconcile")
            {
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Report;
                RunObject = report "Inventory to G/L Reconcile";
            }
            action("&Units of Measure")
            {
                ApplicationArea = All;
                Image = UnitOfMeasure;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = page "Item Units of Measure";
                RunPageLink = "Item No." = field("No.");
            }
            action("Cross Re&ferences")
            {
                ApplicationArea = All;
                Image = Change;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = page "Item Cross Reference Entries";
                RunPageLink = "Item No." = field("No.");
            }
            action("Item Master")
            {
                ApplicationArea = All;
                Image = TaskPage;
                Promoted = true;
                PromotedCategory = Category4;
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
            action("&Create Stockkeeping Unit")
            {
                ApplicationArea = All;
                Image = CreateSKU;
                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.SETRANGE("No.", "No.");
                    REPORT.RUNMODAL(REPORT::"Create Stockkeeping Unit", TRUE, FALSE, Item);
                end;
            }
            action("C&alculate Counting Period")
            {
                ApplicationArea = All;
                Image = CalculateCalendar;
                Promoted = true;
                PromotedCategory = Category20;
                trigger OnAction()
                var
                    Item: Record Item;
                    PhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
                begin
                    CurrPage.SETSELECTIONFILTER(Item);
                    PhysInvtCountMgt.UpdateItemPhysInvtCount(Item);
                end;
            }
        }


    }


    trigger OnOpenPage()
    BEGIN
        jfHideItems;
    END;

    trigger OnAfterGetCurrRecord()
    VAR
        SalesType: Option "PropertyValueOptionCaptionCustomer","Customer Price Group","All Customers","Campaign",,,,,,,"Customer Buying Group","Price List Group";
    BEGIN
        IF "No." <> '' THEN BEGIN
            CurrPage.ItemAvailMatrixSubPage.PAGE.SetItem(Rec);
            CurrPage."Standard Prices".PAGE.Set(Rec, SalesType::"Price List Group");
            CurrPage."Sales Prices".PAGE.Set(Rec, SalesType::"Customer Price Group");
            CurrPage.Update(false);
        END;
    END;

    PROCEDURE GetSelectionFilter(): Text;
    VAR
        Item: Record 27;
        SelectionFilterManagement: Codeunit 46;
    BEGIN
        CurrPage.SETSELECTIONFILTER(Item);
        EXIT(SelectionFilterManagement.GetSelectionFilterForItem(Item));
    END;

    PROCEDURE SetSelection(VAR Item: Record 27);
    BEGIN
        CurrPage.SETSELECTIONFILTER(Item);
    END;

    PROCEDURE jfHideItems();
    BEGIN
        //<JF3978MG>
        grecInvSetup.GET;

        CASE grecInvSetup."Hide Items on Lookup ELA" OF
            grecInvSetup."Hide Items on Lookup ELA"::None:
                BEGIN
                    //-- do nothing (to maintain any user-defined filtering)
                END;
            grecInvSetup."Hide Items on Lookup ELA"::"Blocked and Closed":
                BEGIN
                    SETRANGE(Blocked, FALSE);
                    SETFILTER("Item Status ELA", '<>%1', "Item Status ELA"::Closed);
                END;
            grecInvSetup."Hide Items on Lookup ELA"::"Blocked Only":
                BEGIN
                    SETRANGE(Blocked, FALSE);
                    SETRANGE("Item Status ELA");
                END;
            grecInvSetup."Hide Items on Lookup ELA"::"Closed Only":
                BEGIN
                    SETRANGE(Blocked);
                    SETFILTER("Item Status ELA", '<>%1', "Item Status ELA"::Closed);
                END;
        END;
        //</JF3978MG>
    END;

    VAR
        SkilledResourceList: Page "Skilled Resource List";
        CalculateStdCost: Codeunit 5812;
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        grecInvSetup: Record 313;
        gtxtSpecial: Text[250];
}

