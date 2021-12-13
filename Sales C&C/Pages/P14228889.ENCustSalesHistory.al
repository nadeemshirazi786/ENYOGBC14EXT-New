page 14228889 "EN Cust. Sales History"
{
    Caption = 'Customer Sales History';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Buffer ELA";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            group(Control23019011)
            {
                ShowCaption = false;
                field(CurrentMenuType; CurrentMenuType)
                {

                    trigger OnValidate()
                    begin
                        SetRecords;
                    end;
                }
            }
            repeater(Control23019002)
            {
                ShowCaption = false;
                field(Code1; Code1)
                {
                    Caption = 'Document No.';
                }
                field(Date1; Date1)
                {
                    Caption = 'Shipment Date';
                }
                field(Code4; Code4)
                {
                    Caption = 'Sell-to Customer No.';
                }
                field(Code5; Code5)
                {
                    Caption = 'Bill-to Customer No.';
                }
                field(Text1; Text1)
                {
                    Caption = 'Type';
                }
                field(Code2; Code2)
                {
                    Caption = 'No.';
                }
                field(Text2; Text2)
                {
                    Caption = 'Description';
                }
                field(Decimal1; Decimal1)
                {
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                }
                field(Code3; Code3)
                {
                    Caption = 'Unit of Measure Code';
                }
                field(Decimal2; Decimal2)
                {
                    Caption = 'Unit Price';
                }
                field(Decimal3; Decimal3)
                {
                    Caption = 'Amount';
                }
            }
        }
        area(factboxes)
        {
            part(Control23019017; "Sales Hist. Sell-to FactBox")
            {
                SubPageLink = "No." = FIELD(Code11);
            }
            systempart(Control1900383207; Links)
            {
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("Copy to Document")
                {
                    Caption = 'Copy to Document';
                    Image = Copy;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        CopyLineToDoc;

                        CurrPage.Close;
                    end;
                }
            }
        }
        area(navigation)
        {
            action("<Action23019016>")
            {
                Caption = 'Show Document';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    ShowDocument;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrentMenuType := CurrentMenuType::Quote;

        SetRecords;
    end;

    var
        ToSalesHeader: Record "Sales Header";
        SalesInfoPaneMgt: Codeunit "Sales Info-Pane Management";
        OldMenuType: Integer;
        BillTo: Boolean;
        gcodCustomer: Code[20];
        CurrentMenuType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Shipments","Posted Invoices","Posted Return Orders","Posted Cr. Memos","Archived Orders";
        grecSalesLine: Record "Sales Line";
        grecShipmentLine: Record "Sales Shipment Line";
        grecInvoiceLine: Record "Sales Invoice Line";
        grecReturnReceiptLine: Record "Return Receipt Line";
        grecCrMemoLine: Record "Sales Cr.Memo Line";
        grecSalesLineArchive: Record "Sales Line Archive";
        grecFromBuffer: Record "Buffer ELA" temporary;

    local procedure CopyLineToDoc()
    var
        FromSalesLine: Record "Sales Line";
        FromSalesShptLine: Record "Sales Shipment Line";
        FromSalesInvLine: Record "Sales Invoice Line";
        FromSalesCrMemoLine: Record "Sales Cr.Memo Line";
        FromReturnRcptLine: Record "Return Receipt Line";
        FromSalesArchLine: Record "Sales Line Archive";
    begin
        grecFromBuffer.DeleteAll;
        CurrPage.SetSelectionFilter(Rec);
        if Rec.FindSet then begin
            repeat
                grecFromBuffer := Rec;
                grecFromBuffer.Insert;
            until Rec.Next = 0;
        end;


        case CurrentMenuType of

        /*CurrentMenuType::Quote..CurrentMenuType::"Return Order":
          BEGIN
            grecFromBuffer.RESET;
            IF grecFromBuffer.FINDSET THEN BEGIN
              REPEAT
                FromSalesLine.SETRANGE("Document Type",CurrentMenuType);
                FromSalesLine.SETRANGE("Document No.",grecFromBuffer.Code1);
                FromSalesLine.SETRANGE("Line No.",grecFromBuffer.Integer1);
                SalesHistCopyLineMgt.CopySalesLinesToDoc(ToSalesHeader,FromSalesLine,CurrentMenuType);
              UNTIL grecFromBuffer.NEXT = 0;
            END;
          END;

        CurrentMenuType::"Posted Shipments":
          BEGIN
            grecFromBuffer.RESET;
            IF grecFromBuffer.FINDSET THEN BEGIN
              REPEAT
                FromSalesShptLine.SETRANGE("Document No.",grecFromBuffer.Code1);
                FromSalesShptLine.SETRANGE("Line No.",grecFromBuffer.Integer1);
                SalesHistCopyLineMgt.CopySalesShptLineToDoc(ToSalesHeader,FromSalesShptLine,CurrentMenuType);
              UNTIL grecFromBuffer.NEXT = 0;
            END;
          END;

        CurrentMenuType::"Posted Invoices":
          BEGIN
            grecFromBuffer.RESET;
            IF grecFromBuffer.FINDSET THEN BEGIN
              REPEAT
                FromSalesInvLine.SETRANGE("Document No.",grecFromBuffer.Code1);
                FromSalesInvLine.SETRANGE("Line No.",grecFromBuffer.Integer1);
                SalesHistCopyLineMgt.CopySalesInvLineToDoc(ToSalesHeader,FromSalesInvLine,CurrentMenuType);
              UNTIL grecFromBuffer.NEXT = 0;
            END;
          END;

        CurrentMenuType::"Posted Return Orders":
          BEGIN
            grecFromBuffer.RESET;
            IF grecFromBuffer.FINDSET THEN BEGIN
              REPEAT
                FromReturnRcptLine.SETRANGE("Document No.",grecFromBuffer.Code1);
                FromReturnRcptLine.SETRANGE("Line No.",grecFromBuffer.Integer1);
                SalesHistCopyLineMgt.CopyReturnRcptLineToDoc(ToSalesHeader,FromReturnRcptLine,CurrentMenuType);
              UNTIL grecFromBuffer.NEXT = 0;
            END;
          END;

        CurrentMenuType::"Posted Cr. Memos":
          BEGIN
            grecFromBuffer.RESET;
            IF grecFromBuffer.FINDSET THEN BEGIN
              REPEAT
                FromSalesCrMemoLine.SETRANGE("Document No.",grecFromBuffer.Code1);
                FromSalesCrMemoLine.SETRANGE("Line No.",grecFromBuffer.Integer1);
                SalesHistCopyLineMgt.CopySalesCrMemoLineToDoc(ToSalesHeader,FromSalesCrMemoLine,CurrentMenuType);
              UNTIL grecFromBuffer.NEXT = 0;
            END;
          END;

        CurrentMenuType::"Archived Orders":
          BEGIN
            grecFromBuffer.RESET;
            IF grecFromBuffer.FINDSET THEN BEGIN
              REPEAT
                FromSalesArchLine.SETRANGE("Document Type",FromSalesArchLine."Document Type"::Order);
                FromSalesArchLine.SETRANGE("Document No.",grecFromBuffer.Code1);
                FromSalesArchLine.SETRANGE("Line No.",grecFromBuffer.Integer1);
                SalesHistCopyLineMgt.CopySalesArchLineToDoc(ToSalesHeader,FromSalesArchLine,CurrentMenuType);
              UNTIL grecFromBuffer.NEXT = 0;
            END;
          END;
           *///TBR
        end;

    end;


    procedure SetToSalesHeader(NewToSalesHeader: Record "Sales Header"; UseBillTo: Boolean)
    begin
        ToSalesHeader := NewToSalesHeader;
        BillTo := UseBillTo;
    end;


    procedure SetRecords()
    begin
        Clear(Rec);
        DeleteAll;

        case CurrentMenuType of

            CurrentMenuType::Quote .. CurrentMenuType::"Return Order":
                begin
                    grecSalesLine.SetRange("Document Type", CurrentMenuType);
                    if BillTo then begin
                        grecSalesLine.SetRange("Bill-to Customer No.", ToSalesHeader."Bill-to Customer No.");
                    end else begin
                        grecSalesLine.SetRange("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                    end;


                    if grecSalesLine.FindSet then begin
                        repeat
                            Key1 := Format(grecSalesLine."Document Type");
                            Key2 := grecSalesLine."Document No.";
                            Key3 := Format(grecSalesLine."Line No.");
                            Integer0 := grecSalesLine."Document Type";
                            Code1 := grecSalesLine."Document No.";
                            Integer1 := grecSalesLine."Line No.";
                            Text1 := Format(grecSalesLine.Type);
                            Code2 := grecSalesLine."No.";
                            Text2 := grecSalesLine.Description;
                            Decimal1 := grecSalesLine.Quantity;
                            Code3 := grecSalesLine."Unit of Measure Code";
                            Code4 := grecSalesLine."Sell-to Customer No.";
                            Code5 := grecSalesLine."Bill-to Customer No.";
                            Date1 := grecSalesLine."Shipment Date";
                            Decimal2 := grecSalesLine."Unit Price";
                            Decimal3 := grecSalesLine.Amount;

                            if BillTo then begin
                                Code11 := ToSalesHeader."Bill-to Customer No.";
                            end else begin
                                Code11 := ToSalesHeader."Sell-to Customer No.";
                            end;
                            Insert;

                        until grecSalesLine.Next = 0;
                    end;
                end;

            CurrentMenuType::"Posted Shipments":
                begin
                    if BillTo then begin
                        grecShipmentLine.SetRange("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                    end else begin
                        grecShipmentLine.SetRange("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                    end;
                    if grecShipmentLine.FindSet then begin
                        repeat
                            Key1 := Format(CurrentMenuType);
                            Key2 := grecShipmentLine."Document No.";
                            Key3 := Format(grecShipmentLine."Line No.");
                            Integer0 := CurrentMenuType;
                            Code1 := grecShipmentLine."Document No.";
                            Integer1 := grecShipmentLine."Line No.";
                            Text1 := Format(grecShipmentLine.Type);
                            Code2 := grecShipmentLine."No.";
                            Text2 := grecShipmentLine.Description;
                            Decimal1 := grecShipmentLine.Quantity;
                            Code3 := grecShipmentLine."Unit of Measure Code";
                            Code4 := grecShipmentLine."Sell-to Customer No.";
                            Code5 := grecShipmentLine."Bill-to Customer No.";
                            Date1 := grecShipmentLine."Shipment Date";
                            Decimal2 := grecShipmentLine."Unit Price";
                            Decimal3 := Round(grecShipmentLine."Unit Price" * grecShipmentLine.Quantity, 0.01);

                            if BillTo then begin
                                Code11 := ToSalesHeader."Bill-to Customer No.";
                            end else begin
                                Code11 := ToSalesHeader."Sell-to Customer No.";
                            end;

                            Insert;

                        until grecShipmentLine.Next = 0;
                    end;
                end;

            CurrentMenuType::"Posted Invoices":
                begin
                    if BillTo then begin
                        grecInvoiceLine.SetRange("Sell-to Customer No.", ToSalesHeader."Bill-to Customer No.");
                    end else begin
                        grecInvoiceLine.SetRange("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                    end;
                    if grecInvoiceLine.FindSet then begin
                        repeat
                            Key1 := Format(CurrentMenuType);
                            Key2 := grecInvoiceLine."Document No.";
                            Key3 := Format(grecInvoiceLine."Line No.");
                            Integer0 := CurrentMenuType;
                            Code1 := grecInvoiceLine."Document No.";
                            Integer1 := grecInvoiceLine."Line No.";
                            Text1 := Format(grecInvoiceLine.Type);
                            Code2 := grecInvoiceLine."No.";
                            Text2 := grecInvoiceLine.Description;
                            Decimal1 := grecInvoiceLine.Quantity;
                            Code3 := grecInvoiceLine."Unit of Measure Code";
                            Code4 := grecInvoiceLine."Sell-to Customer No.";
                            Code5 := grecInvoiceLine."Bill-to Customer No.";
                            Date1 := grecInvoiceLine."Shipment Date";
                            Decimal2 := grecInvoiceLine."Unit Price";
                            Decimal3 := grecInvoiceLine.Amount;
                            if BillTo then begin
                                Code11 := ToSalesHeader."Bill-to Customer No.";
                            end else begin
                                Code11 := ToSalesHeader."Sell-to Customer No.";
                            end;

                            Insert;

                        until grecInvoiceLine.Next = 0;
                    end;
                end;

            CurrentMenuType::"Posted Return Orders":
                begin
                    if BillTo then begin
                        grecReturnReceiptLine.SetRange("Sell-to Customer No.", ToSalesHeader."Bill-to Customer No.");
                    end else begin
                        grecReturnReceiptLine.SetRange("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                    end;
                    if grecReturnReceiptLine.FindSet then begin
                        repeat
                            Key1 := Format(CurrentMenuType);
                            Key2 := grecReturnReceiptLine."Document No.";
                            Key3 := Format(grecReturnReceiptLine."Line No.");
                            Integer0 := CurrentMenuType;
                            Code1 := grecReturnReceiptLine."Document No.";
                            Integer1 := grecReturnReceiptLine."Line No.";
                            Text1 := Format(grecReturnReceiptLine.Type);
                            Code2 := grecReturnReceiptLine."No.";
                            Text2 := grecReturnReceiptLine.Description;
                            Decimal1 := grecReturnReceiptLine.Quantity;
                            Code3 := grecReturnReceiptLine."Unit of Measure Code";
                            Code4 := grecReturnReceiptLine."Sell-to Customer No.";
                            Code5 := grecReturnReceiptLine."Bill-to Customer No.";
                            Date1 := grecReturnReceiptLine."Shipment Date";
                            Decimal2 := grecReturnReceiptLine."Unit Price";
                            Decimal3 := Round(grecReturnReceiptLine."Unit Price" * grecReturnReceiptLine.Quantity, 0.01);

                            if BillTo then begin
                                Code11 := ToSalesHeader."Bill-to Customer No.";
                            end else begin
                                Code11 := ToSalesHeader."Sell-to Customer No.";
                            end;

                            Insert;

                        until grecReturnReceiptLine.Next = 0;
                    end;
                end;

            CurrentMenuType::"Posted Cr. Memos":
                begin
                    if BillTo then begin
                        grecCrMemoLine.SetRange("Sell-to Customer No.", ToSalesHeader."Bill-to Customer No.");
                    end else begin
                        grecCrMemoLine.SetRange("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                    end;
                    if grecCrMemoLine.FindSet then begin
                        repeat
                            Key1 := Format(CurrentMenuType);
                            Key2 := grecCrMemoLine."Document No.";
                            Key3 := Format(grecCrMemoLine."Line No.");
                            Integer0 := CurrentMenuType;
                            Code1 := grecCrMemoLine."Document No.";
                            Integer1 := grecCrMemoLine."Line No.";
                            Text1 := Format(grecCrMemoLine.Type);
                            Code2 := grecCrMemoLine."No.";
                            Text2 := grecCrMemoLine.Description;
                            Decimal1 := grecCrMemoLine.Quantity;
                            Code3 := grecCrMemoLine."Unit of Measure Code";
                            Code4 := grecCrMemoLine."Sell-to Customer No.";
                            Code5 := grecCrMemoLine."Bill-to Customer No.";
                            Date1 := grecCrMemoLine."Shipment Date";
                            Decimal2 := grecCrMemoLine."Unit Price";
                            Decimal3 := grecCrMemoLine.Amount;

                            if BillTo then begin
                                Code11 := ToSalesHeader."Bill-to Customer No.";
                            end else begin
                                Code11 := ToSalesHeader."Sell-to Customer No.";
                            end;

                            Insert;

                        until grecCrMemoLine.Next = 0;
                    end;
                end;

            CurrentMenuType::"Archived Orders":
                begin
                    grecSalesLineArchive.SetRange("Document Type", grecSalesLineArchive."Document Type"::Order);
                    if BillTo then begin
                        grecSalesLineArchive.SetRange("Sell-to Customer No.", ToSalesHeader."Bill-to Customer No.");
                    end else begin
                        grecSalesLineArchive.SetRange("Sell-to Customer No.", ToSalesHeader."Sell-to Customer No.");
                    end;

                    if grecSalesLineArchive.FindSet then begin
                        repeat
                            Key1 := Format(1);
                            Key2 := grecSalesLineArchive."Document No.";
                            Key3 := Format(grecSalesLineArchive."Line No.");
                            Key4 := Format(grecSalesLineArchive."Doc. No. Occurrence");
                            Key5 := Format(grecSalesLineArchive."Version No.");
                            Integer0 := CurrentMenuType;
                            Code1 := grecSalesLineArchive."Document No.";
                            Integer1 := grecSalesLineArchive."Line No.";
                            Text1 := Format(grecSalesLineArchive.Type);
                            Code2 := grecSalesLineArchive."No.";
                            Text2 := grecSalesLineArchive.Description;
                            Decimal1 := grecSalesLineArchive.Quantity;
                            Code3 := grecSalesLineArchive."Unit of Measure Code";
                            Code4 := grecSalesLineArchive."Sell-to Customer No.";
                            Code5 := grecSalesLineArchive."Bill-to Customer No.";
                            Date1 := grecSalesLineArchive."Shipment Date";
                            Decimal2 := grecSalesLineArchive."Unit Price";
                            Decimal3 := grecSalesLineArchive.Amount;
                            if BillTo then begin
                                Code11 := ToSalesHeader."Bill-to Customer No.";
                            end else begin
                                Code11 := ToSalesHeader."Sell-to Customer No.";
                            end;

                            Insert;

                        until grecSalesLineArchive.Next = 0;
                    end;
                end;

        end;

        if Rec.IsEmpty then begin
            Key1 := '';
            Key2 := '';
            Key3 := '';
            if BillTo then begin
                Code11 := ToSalesHeader."Bill-to Customer No.";
            end else begin
                Code11 := ToSalesHeader."Sell-to Customer No.";
            end;

            Insert;
        end;
    end;


    procedure ShowDocument()
    var
        SalesHeader: Record "Sales Header";
        SalesShptHeader: Record "Sales Shipment Header";
        SalesInvHeader: Record "Sales Invoice Header";
        ReturnRcptHeader: Record "Return Receipt Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesHeaderArchive: Record "Sales Header Archive";
    begin
        case CurrentMenuType of

            CurrentMenuType::Quote .. CurrentMenuType::"Return Order":
                begin
                    if not SalesHeader.Get(Integer0, Code1) then
                        exit;
                    case CurrentMenuType of
                        CurrentMenuType::Quote:
                            PAGE.Run(PAGE::"Sales Quote", SalesHeader);
                        CurrentMenuType::Order:
                            PAGE.Run(PAGE::"Sales Order", SalesHeader);
                        CurrentMenuType::Invoice:
                            PAGE.Run(PAGE::"Sales Invoice", SalesHeader);
                        CurrentMenuType::"Credit Memo":
                            PAGE.Run(PAGE::"Sales Credit Memo", SalesHeader);
                        CurrentMenuType::"Blanket Order":
                            PAGE.Run(PAGE::"Blanket Sales Order", SalesHeader);
                        CurrentMenuType::"Return Order":
                            PAGE.Run(PAGE::"Sales Return Order", SalesHeader);
                    end;
                end;

            CurrentMenuType::"Posted Shipments":
                begin
                    if not SalesShptHeader.Get(Code1) then
                        exit;
                    PAGE.Run(PAGE::"Posted Sales Shipment", SalesShptHeader);
                end;

            CurrentMenuType::"Posted Invoices":
                begin
                    if not SalesInvHeader.Get(Code1) then
                        exit;
                    PAGE.Run(PAGE::"Posted Sales Invoice", SalesInvHeader);
                end;

            CurrentMenuType::"Posted Return Orders":
                begin
                    if not ReturnRcptHeader.Get(Code1) then
                        exit;
                    PAGE.Run(PAGE::"Posted Return Receipt", ReturnRcptHeader);
                end;

            CurrentMenuType::"Posted Cr. Memos":
                begin
                    if not SalesCrMemoHeader.Get(Code1) then
                        exit;
                    PAGE.Run(PAGE::"Posted Sales Credit Memo", SalesCrMemoHeader);
                end;

            CurrentMenuType::"Archived Orders":
                begin
                    if not SalesHeaderArchive.Get(1, Code1, Key4, Key5) then
                        exit;
                    PAGE.Run(PAGE::"Sales Order Archive", SalesHeaderArchive);
                end;

        end;
    end;
}

