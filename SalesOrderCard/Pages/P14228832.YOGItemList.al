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
        area(Navigation)
        {
            group("Item by Location")
            {
                group("Item Availability")
                {
                    action("Event")
                    {
                        Image = "Event";
                        Caption = 'Event';
                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByEvent);
                        end;
                    }
                    action("Period")
                    {
                        Image = Period;
                        Caption = 'Period';
                        RunObject = Page "Item Availability by Periods";
                        RunPageLink = "No." = FIELD("No."), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Variant Filter" = FIELD("Variant Filter");
                    }
                    action("V@riant")
                    {
                        Image = ItemVariant;
                        Caption = 'Variant';
                        RunObject = page "Item Availability by Variant";
                        RunPageLink = "No." = FIELD("No."), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Variant Filter" = FIELD("Variant Filter");
                    }
                    action("Location")
                    {
                        Image = Warehouse;
                        Caption = 'Location';
                        RunObject = page "Item Availability by Location";
                        RunPageLink = "No." = FIELD("No."), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Variant Filter" = FIELD("Variant Filter");
                    }
                    action("BOM Level")
                    {
                        Image = BOMLevel;
                        Caption = 'BOM Level';
                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromItem(Rec, ItemAvailFormsMgt.ByBOM);
                        end;
                    }
                    action("Timeline")
                    {
                        Image = Timeline;
                        Caption = 'Timeline';
                        trigger OnAction()
                        begin
                            ShowTimelineFromItem(Rec);
                        end;
                    }
                }
                action("Inventory Overview")
                {
                    Image = BinLedger;
                    Caption = 'Inventory Overview';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }
            }
            group("Master Data")
            {
                action("Variant")
                {
                    Image = ItemVariant;
                    Caption = 'Variant';
                    RunObject = page "Item Variants";
                    RunPageLink = "Item No." = FIELD("No.");
                }
                action("Item Unit of Measure")
                {
                    Image = UnitOfMeasure;
                    Caption = 'Unit of Measure';
                    RunObject = page "Item Units of Measure";
                    RunPageLink = "Item No." = FIELD("No.");
                }
                group("Dimensions")
                {
                    action("Dimension Single")
                    {
                        ApplicationArea = All;
                        Caption = 'Dimension-Single';
                        RunObject = page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(27), "No." = FIELD("No.");
                        Image = Dimensions;
                    }
                    action("Dimension Multiple")
                    {
                        ApplicationArea = All;
                        Caption = 'Dimension-Multiple';
                        Image = DimensionSets;
                        trigger OnAction()
                        var
                            Item: Record Item;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SETSELECTIONFILTER(Item);
                            //DefaultDimMultiple.SetMultiItem(Item);
                            DefaultDimMultiple.RUNMODAL;
                        end;
                    }
                }
                action("Item Substitutions")
                {
                    ApplicationArea = All;
                    Caption = 'Substituti&ons';
                    Image = ItemSubstitution;
                    RunObject = page "Item Substitution Entry";
                    RunPageLink = "Type" = CONST(Item), "No." = FIELD("No.");
                }
                action("Item Cross Re&ferences")
                {
                    ApplicationArea = All;
                    Caption = 'Cross References';
                    Image = Change;
                    RunObject = page "Item Cross Reference Entries";
                    RunPageLink = "Item No." = FIELD("No.");
                }
                action("E&xtended Text")
                {
                    ApplicationArea = All;
                    Caption = 'Extended Text';
                    Image = Text;
                    RunObject = page "Extended Text List";
                    RunPageView = SORTING("Table Name", "No.", "Language Code", "All Language Codes", "Starting Date", "Ending Date");
                    RunPageLink = "Table Name" = CONST(Item), "No." = FIELD("No.");
                }
                action("Item Translation")
                {
                    ApplicationArea = All;
                    Caption = 'Translation';
                    Image = Translations;
                    RunObject = page "Item Translations";
                    RunPageLink = "Item No." = FIELD("No."), "Variant Code" = CONST();
                }
                action("&Picture")
                {
                    ApplicationArea = All;
                    Caption = 'Picture';
                    Image = Picture;
                    RunObject = page "Item Picture";
                    RunPageLink = "No." = FIELD("No."), "Date Filter" = FIELD("Date Filter"), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Variant Filter" = FIELD("Variant Filter");
                }
                action("Item Identifiers")
                {
                    ApplicationArea = All;
                    Caption = 'Identifiers';
                    Image = BarCode;
                    RunObject = page "Item Identifiers";
                    RunPageView = SORTING("Item No.", "Variant Code", "Unit of Measure Code");
                    RunPageLink = "Item No." = FIELD("No.");
                }
            }
            group("History")
            {
                group("Entries")
                {
                    action("Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Ledger Entries';
                        Image = ItemLedger;
                        Promoted = true;
                        PromotedCategory = Process;
                        RunObject = page "Item Ledger Entries";
                        RunPageView = sorting("Item No.");
                        RunPageLink = "Item No." = FIELD("No.");
                    }
                    action("&Reservation Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Reservation Entries';
                        Image = ReservationLedger;
                        RunObject = page "Reservation Entries";
                        RunPageView = SORTING("Item No.", "Variant Code", "Location Code", "Reservation Status");
                        RunPageLink = "Reservation Status" = CONST(Reservation), "Item No." = FIELD("No.");

                    }
                    action("&Phys. Inventory Ledger Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Phys. Inventory Ledger Entries';
                        Image = PhysicalInventoryLedger;
                        RunObject = page "Phys. Inventory Ledger Entries";
                        RunPageView = sorting("Item No.");
                        RunPageLink = "Item No." = field("No.");
                    }
                    action("&Value Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Value Entries';
                        Image = ValueLedger;
                        RunObject = page "Value Entries";
                        RunPageView = sorting("Item No.");
                        RunPageLink = "Item No." = field("No.");
                    }
                    action("Item &Tracking Entries")
                    {
                        ApplicationArea = All;
                        Caption = 'Item Tracking Entries';
                        Image = ItemTrackingLedger;
                        trigger OnAction()
                        var
                            ItemTrackingMgt: Codeunit "Item Tracking Management";
                        begin
                            //ItemTrackingMgt.CallItemTrackingEntryForm(3, '', "No.", '', '', '', '');
                        end;
                    }
                    action("&Warehouse Entries")
                    {
                        ApplicationArea = All;
                        Caption = '&Warehouse Entries';
                        Image = BinLedger;
                        RunObject = page "Warehouse Entries";
                        RunPageView = SORTING("Item No.", "Bin Code", "Location Code", "Variant Code", "Unit of Measure Code", "Lot No.", "Serial No.", "Entry Type", Dedicated);
                        RunPageLink = "Item No." = field("No.");
                    }
                }
                group("Statistics")
                {
                    action("St@tistics")
                    {
                        ApplicationArea = All;
                        Caption = 'Statistics';
                        Image = Statistics;
                        Promoted = true;
                        PromotedCategory = Process;
                        trigger OnAction()
                        var
                            ItemStatistics: Page "Item Statistics";
                        begin
                            ItemStatistics.SetItem(Rec);
                            ItemStatistics.RUNMODAL;
                        end;
                    }
                    action("Item Entry Statistics")
                    {
                        ApplicationArea = All;
                        Caption = 'Entry Statistics';
                        Image = EntryStatistics;
                        RunObject = page "Item Entry Statistics";
                        RunPageLink = "No." = FIELD("No."), "Date Filter" = FIELD("Date Filter"), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Variant Filter" = FIELD("Variant Filter");

                    }
                    action("T&urnover")
                    {
                        ApplicationArea = All;
                        Caption = 'Turnover';
                        Image = Turnover;
                        RunObject = page "Item Turnover";
                        RunPageLink = "No." = FIELD("No."), "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"), "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"), "Location Filter" = FIELD("Location Filter"), "Drop Shipment Filter" = FIELD("Drop Shipment Filter"), "Variant Filter" = FIELD("Variant Filter");

                    }
                }
            }
            group("Sales")
            {
                action("&Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = page "Sales Orders";
                    RunPageView = SORTING("Document Type", Type, "No.");
                    RunPageLink = Type = CONST(Item), "No." = FIELD("No.");
                }
                action("Returns Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Returns Orders';
                    Image = ReturnOrder;
                    RunObject = page "Sales Return Orders";
                    RunPageView = SORTING("Document Type", Type, "No.");
                    RunPageLink = Type = CONST(Item), "No." = FIELD("No.");
                }
            }
            group("&Purchases")
            {
                action("Ven&dors")
                {
                    ApplicationArea = All;
                    Caption = 'Vendors';
                    Image = Vendor;
                    RunObject = page "Item Vendor Catalog";
                    RunPageView = sorting("Item No.");
                    RunPageLink = "Item No." = field("No.");
                }
                action("&Purchase Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Orders';
                    Image = Document;
                    RunObject = page "Purchase Orders";
                    RunPageView = SORTING("Document Type", Type, "No.");
                    RunPageLink = Type = CONST(Item), "No." = FIELD("No.");
                }
                action("Purchase Returns Orders")
                {
                    ApplicationArea = All;
                    Caption = 'Returns Orders';
                    Image = ReturnOrder;
                    RunObject = page "Purchase Return Orders";
                    RunPageView = SORTING("Document Type", Type, "No.");
                    RunPageLink = Type = CONST(Item), "No." = FIELD("No.");
                }
            }
            group("Warehouse")
            {
                action("Item Bin Contents")
                {
                    ApplicationArea = All;
                    Caption = '&Bin Contents';
                    Image = BinContent;
                    RunObject = page "Item Bin Contents";
                    RunPageView = sorting("Item No.");
                    RunPageLink = "Item No." = field("No.");
                }
                action("Stockkeepin&g Units List")
                {
                    ApplicationArea = All;
                    Caption = 'Stockkeeping Units';
                    Image = SKU;
                    RunObject = page "Stockkeeping Unit List";
                    RunPageView = sorting("Item No.");
                    RunPageLink = "Item No." = field("No.");
                }
                action("Warehouse Overview")
                {
                    ApplicationArea = All;
                    Caption = 'Warehouse Overview';
                    Image = Warehouse;
                    //RunObject = page Warehouse o

                }
            }
            group("Resource")
            {
                action("Skilled R&esources")
                {
                    ApplicationArea = All;
                    Caption = 'Skilled Resources';
                    Image = ResourceSkills;
                    trigger OnAction()
                    var
                        ResourceSkill: Record "Resource Skill";
                    begin
                        CLEAR(SkilledResourceList);
                        SkilledResourceList.Initialize(ResourceSkill.Type::Item, "No.", Description);
                        SkilledResourceList.RUNMODAL;
                    end;
                }
            }
        }



    }


    trigger OnOpenPage()
    BEGIN
        jfHideItems;
    END;

    trigger OnAfterGetCurrRecord()
    VAR
        SalesType: Option "Customer","Customer Price Group","All Customers","Campaign","Customer Buying Group","Price List Group";
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

