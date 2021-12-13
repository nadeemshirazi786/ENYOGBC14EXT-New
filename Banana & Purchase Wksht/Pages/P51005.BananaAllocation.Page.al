page 51005 "Banana Allocation"
{
    InsertAllowed = false;
    PageType = List;
    ApplicationArea = all;
    UsageCategory = Lists;
    SourceTable = "Banana Allocation";

    layout
    {
        area(content)
        {
            group(Control1101769009)
            {
                ShowCaption = false;
                field("<ItemNo>"; ItemNo)
                {
                    Caption = 'Item';
                    DrillDown = false;
                    Lookup = true;
                    LookupPageID = "Item List";
                    TableRelation = Item."No.";
                }
                field(ShipDate; ShipDate)
                {
                    Caption = 'Shipment Date';
                }
                field(QtyBreaking; QtyBreaking)
                {
                    Caption = 'Breaking Quantity to Allocate';
                }
                field(TotalBreaking; TotalBreaking)
                {
                    Caption = 'Breaking Quantity Allocated';
                    Editable = false;
                }
            }
            repeater(Group)
            {
                field("Order No."; "Order No.")
                {
                }
                field("Order Line No."; "Order Line No.")
                {
                }
                field("Customer No."; "Customer No.")
                {
                }
                field("Shipment Date"; "Shipment Date")
                {
                }
                field("Total Quantity"; "Total Quantity")
                {
                }
                field("Breaking Quantity"; "Breaking Quantity")
                {

                    trigger OnValidate()
                    begin
                        TotalBreaking := TotalBreaking + ("Breaking Quantity") - xRec."Breaking Quantity";
                        CurrPage.Update;
                    end;
                }
                field("Green Quantity"; "Green Quantity")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("<Action130>")
            {
                Caption = 'F&unctions';
                action("Load Orders")
                {
                    Image = GetSourceDoc;
                    Promoted = true;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        LoadOrders;
                        CalcTotal;
                        CurrPage.Update;
                    end;
                }
                action(Allocate)
                {
                    Image = Allocate;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        Allocation;
                        CalcTotal;
                        CurrPage.Update;
                    end;
                }
                action("Update Orders")
                {
                    Image = Apply;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        UpdateOrders;
                        ShipDate := 0D;
                        SetFilters;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        DeleteAll;
    end;

    var
        ShipDate: Date;
        ItemNo: Code[20];
        QtyBreaking: Integer;
        TotalBreaking: Decimal;
        gText000: Label 'Shipment date must be entered.';
        gText001: Label 'This will delete all allocation lines for %1 and reload the orders.  Continue?';
        gText002: Label 'Nothing to allocate.';
        gText003: Label 'This will reset all breaking quantities.  Continue?';
        gText004: Label 'Item must be entered.';

    [Scope('Internal')]
    procedure SetFilters()
    begin
        FilterGroup(2);
        SetRange("Shipment Date", ShipDate);
        FilterGroup(0);

        CalcTotal;
        CurrPage.Update;
    end;

    [Scope('Internal')]
    procedure CalcTotal()
    var
        BananaAlloc: Record "Banana Allocation";
    begin
        BananaAlloc.SetCurrentKey("Shipment Date");
        BananaAlloc.SetRange("Shipment Date", ShipDate);
        BananaAlloc.CalcSums("Breaking Quantity");
        TotalBreaking := BananaAlloc."Breaking Quantity";
    end;

    [Scope('Internal')]
    procedure LoadOrders()
    var
        BananaAlloc: Record "Banana Allocation";
        SalesHead: Record "Sales Header";
        SalesLine: Record "Sales Line";
        BananaCust: Record "Banana Worksheet Customers";
    begin
        if ItemNo = '' then
            Error(gText003);
        if ShipDate = 0D then
            Error(gText000);

        BananaAlloc.SetCurrentKey("Shipment Date");
        BananaAlloc.SetRange("Shipment Date", ShipDate);

        if BananaAlloc.Find('-') then
            if not Confirm(gText001, false, ShipDate) then
                exit;

        BananaAlloc.DeleteAll;
        BananaAlloc.Reset;
        SalesLine.SetCurrentKey("Document Type", Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Shipment Date");
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", ItemNo);
        SalesLine.SetRange("Drop Shipment", false);
        SalesLine.SetRange("Shipment Date", ShipDate);
        if SalesLine.FindSet then begin
            repeat
                SalesHead.Get(SalesLine."Document Type", SalesLine."Document No.");
                BananaCust.RESET;
                BananaCust.SetRange("Customer No.", SalesHead."Sell-to Customer No.");
                If BananaCust.FindFirst AND BananaCust."Allow Banana Allocation" then begin
                    if (SalesLine."Green Quantity" <> 0) or
                    (SalesLine."Breaking Quantity" <> 0) then begin
                        if not BananaAlloc.Get(SalesLine."Document No.") then begin
                            BananaAlloc.Init;

                            BananaAlloc."Order No." := SalesLine."Document No.";
                            BananaAlloc."Customer No." := SalesLine."Sell-to Customer No.";
                            BananaAlloc."Shipment Date" := SalesLine."Shipment Date";
                            BananaAlloc.Insert;
                        end;

                        BananaAlloc."Order Line No." := SalesLine."Line No.";
                        BananaAlloc."Breaking Quantity" += SalesLine."Breaking Quantity";
                        BananaAlloc."Green Quantity" += SalesLine."Green Quantity";

                        BananaAlloc."Total Quantity" := BananaAlloc."Breaking Quantity" + BananaAlloc."Green Quantity";

                        BananaAlloc.Modify;
                    end;
                end;
            until SalesLine.Next = 0;
        end;
    end;

    procedure Allocation()
    var
        BananaAlloc: Record "Banana Allocation";
        TotQty: Decimal;
        CumTotal: Decimal;
        CumAlloc: Integer;
    begin
        if QtyBreaking = 0 then
            Error(gText002);

        if ShipDate = 0D then
            Error(gText000);

        if not Confirm(gText003, false) then
            exit;

        BananaAlloc.SetCurrentKey("Shipment Date");
        BananaAlloc.SetRange("Shipment Date", ShipDate);

        if BananaAlloc.FindSet then begin
            repeat
                TotQty += BananaAlloc."Total Quantity";
            until BananaAlloc.Next = 0;
        end;

        if QtyBreaking > TotQty then
            QtyBreaking := TotQty;

        if BananaAlloc.Find('-') then
            repeat
                CumTotal += BananaAlloc."Total Quantity";

                BananaAlloc.Validate("Breaking Quantity", Round((QtyBreaking * CumTotal / TotQty) - CumAlloc, 1));

                CumAlloc += BananaAlloc."Breaking Quantity";

                BananaAlloc.Modify;
            until BananaAlloc.Next = 0;

        TotalBreaking := CumAlloc;
    end;

    [Scope('Internal')]
    procedure UpdateOrders()
    var
        BananaAlloc: Record "Banana Allocation";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        lrecSalesHeader: Record "Sales Header";
        loptSHStatus: Option Open,Released,"Pending Approval","Pending Prepayment";
        lcduReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        BananaAlloc.SetCurrentKey("Shipment Date");
        BananaAlloc.SetRange("Shipment Date", ShipDate);
        if BananaAlloc.FindSet then begin
            repeat
                if BananaAlloc."Order Line No." <> 0 then begin
                    SalesLine.Get(SalesLine."Document Type"::Order, BananaAlloc."Order No.", BananaAlloc."Order Line No.");
                    lrecSalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
                    loptSHStatus := lrecSalesHeader.Status;
                    if BananaAlloc."Total Quantity" <> 0 then begin
                        if (SalesLine."Green Quantity" <> BananaAlloc."Green Quantity") or
                           (SalesLine."Breaking Quantity" <> BananaAlloc."Breaking Quantity") then begin
                            if loptSHStatus = loptSHStatus::Released then
                                lcduReleaseSalesDoc.PerformManualReopen(lrecSalesHeader);
                            SalesLine.Get(SalesLine."Document Type"::Order, BananaAlloc."Order No.", BananaAlloc."Order Line No.");
                            SalesLine.Validate("Green Quantity", BananaAlloc."Green Quantity");
                            SalesLine.Validate("Breaking Quantity", BananaAlloc."Breaking Quantity");
                            SalesLine.Modify(true);
                        end;
                    end else begin
                        if loptSHStatus = loptSHStatus::Released then
                            lcduReleaseSalesDoc.PerformManualReopen(lrecSalesHeader);
                        SalesLine.Delete(true);
                    end;
                    if lrecSalesHeader.Status <> loptSHStatus then begin
                        SalesLine.Reset;
                        SalesLine.SetRange("Document Type", lrecSalesHeader."Document Type");
                        SalesLine.SetRange("Document No.", lrecSalesHeader."No.");
                        if SalesLine.FindFirst then
                            lcduReleaseSalesDoc.PerformManualRelease(lrecSalesHeader);
                    end;
                end;
            until BananaAlloc.Next = 0;
        end;
        BananaAlloc.DeleteAll;
    end;
}

