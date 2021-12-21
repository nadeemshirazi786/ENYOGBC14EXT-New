report 14228813 "Order Sheet - Make Orders"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>
    // 
    // JF00000AC
    //   20080714
    //     support "Use Ship Date as Order Date" S&R setup flag
    // 
    // JF4953DD - Order Sheet Item Additions
    //   20090820 - Added request option form field named Shipment Date Override
    //              Modified code throughout to use the SHipment date Overidde value entered where applicable
    // 
    // JF06457AC
    //   20091229
    //     check for duplicate External Document Nos. if Sales Setup::Test Ord. Sht. Dup. Ext. Doc.
    // 
    // JF08476AC
    //   20100507
    //     fix obscure DSD route template error
    //     (need to validate "Sell-To Customer No." before "Shipment Date")
    // 
    // JF8565SHR
    //   20100517 - Add new option to Release Sales Orders to Request Form
    // 
    // JF8797SHR
    //   20100615 - modified function jfdoCreateSalesHeader to set Payment Terms Code and Due Date
    // 
    // JF09573AC
    //   20101004
    //     - in non-"Override Loc. from Route Temp." environments,
    //     use the new "Order Sheet Batch"::Location field to set the Order Location field
    // 
    // JF8943SHR
    //   20101208 - modified function jfdoCreateSalesHeader, conditional setting if Payment Terms and Due Date
    // 
    // JF12700AC
    //   20110510 - add support for new Order Sheet fields "Unit Price" and "Comment"
    // IB50343TZ 20151104 - added code to get print the report
    // IB57023KL 20160304 - Fix Instance Error

    Caption = 'Order Sheet - Make Orders';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Order Sheet Customers";"Order Sheet Customers")
        {
            DataItemTableView = SORTING ("Order Sheet Batch Name", "Line No.");
            RequestFilterFields = "Order Sheet Batch Name", "Sell-to Customer No.", "Ship-to Code", "Date Filter";
            dataitem("Order Sheet Items";"Order Sheet Items")
            {
                DataItemLink = "Order Sheet Batch Name"=FIELD("Order Sheet Batch Name");

                trigger OnAfterGetRecord()
                begin

                    grecOrderSheetDetails.RESET;
                    grecOrderSheetDetails.SETCURRENTKEY(
                      "Order Sheet Batch Name",
                      "Sell-to Customer No.",
                      "Ship-to Code",
                      "Item No.",
                      "Variant Code",
                      "Unit of Measure Code",
                      "Requested Ship Date");

                    grecOrderSheetDetails.SETRANGE("Order Sheet Batch Name", "Order Sheet Customers"."Order Sheet Batch Name");
                    grecOrderSheetDetails.SETRANGE("Sell-to Customer No.", "Order Sheet Customers"."Sell-to Customer No.");
                    grecOrderSheetDetails.SETRANGE("Ship-to Code", "Order Sheet Customers"."Ship-to Code");
                    "Order Sheet Customers".COPYFILTER("Date Filter", grecOrderSheetDetails."Requested Ship Date");
                    grecOrderSheetDetails.SETRANGE("Item No.", "Order Sheet Items"."Item No.");
                    grecOrderSheetDetails.SETRANGE("Variant Code", "Order Sheet Items"."Variant Code");
                    grecOrderSheetDetails.SETRANGE("Unit of Measure Code", "Order Sheet Items"."Unit of Measure Code");
                    grecOrderSheetDetails.SETFILTER("Sales Order No.", '=%1', '');
                    //
                    grecOrderSheetDetails.SETRANGE("External Doc. No.", "Order Sheet Customers"."External Document No.");
                    //


                    IF grecOrderSheetDetails.FIND('-') THEN BEGIN
                        gdlgWindow.UPDATE(4, grecOrderSheetDetails."Item No." + ', ' + grecOrderSheetDetails."Unit of Measure Code");

                        REPEAT
                            grecOrderSheetDetails.SETRANGE("Requested Ship Date", grecOrderSheetDetails."Requested Ship Date");
                            grecOrderSheetDetails.CALCSUMS(Quantity);
                            jfdoCreateSalesLine;
                            grecOrderSheetDetails.FIND('+');

                            grecOrderSheetDetails2.SETRANGE("Order Sheet Batch Name", "Order Sheet Customers"."Order Sheet Batch Name");
                            grecOrderSheetDetails2.SETRANGE("Sell-to Customer No.", "Order Sheet Customers"."Sell-to Customer No.");
                            grecOrderSheetDetails2.SETRANGE("Ship-to Code", "Order Sheet Customers"."Ship-to Code");
                            grecOrderSheetDetails2.SETRANGE("Requested Ship Date", grecOrderSheetDetails."Requested Ship Date");
                            grecOrderSheetDetails2.SETRANGE("Item No.", "Order Sheet Items"."Item No.");
                            grecOrderSheetDetails2.SETRANGE("Variant Code", "Order Sheet Items"."Variant Code");
                            grecOrderSheetDetails2.SETRANGE("Unit of Measure Code", "Order Sheet Items"."Unit of Measure Code");
                            grecOrderSheetDetails2.SETRANGE("Sales Order No.", '');
                            //
                            grecOrderSheetDetails2.SETRANGE("External Doc. No.", "Order Sheet Customers"."External Document No.");
                            //

                            grecOrderSheetDetails2.MODIFYALL("Sales Order No.", grecSalesHeader."No.");

                            "Order Sheet Customers".COPYFILTER("Date Filter", grecOrderSheetDetails."Requested Ship Date");
                        UNTIL grecOrderSheetDetails.NEXT = 0;
                    END;
                    //<IB50343TZ>
                    grecSalesHeader.MARK(TRUE);
                    //</IB50343TZ>
                end;

                trigger OnPostDataItem()
                begin

                    //<JF8565SHR>
                    IF gblnReleaseSO THEN BEGIN
                        CODEUNIT.RUN(414, grecSalesHeader);
                    END;
                    IF gblnCommitPerOrder THEN BEGIN
                        COMMIT;
                    END;
                    //</JF8565SHR>

                    //<IB50343TZ>
                    IF PrintFlag THEN BEGIN
                        COMMIT;
                        grecSalesHeader.MARKEDONLY(TRUE);
                        //<IB57023KL>
                        CLEAR(grepDelTicketBarCode);
                        //</IB57023KL>
                        grepDelTicketBarCode.SETTABLEVIEW(grecSalesHeader);
                        grepDelTicketBarCode.USEREQUESTPAGE(TRUE);
                        grepDelTicketBarCode.RUNMODAL;
                    END;
                    //</IB50343TZ>
                end;
            }

            trigger OnAfterGetRecord()
            var
                lrecSalesHeader: Record "Sales Header";
                lrecSalesInvoice: Record "Sales Invoice Header";
            begin
                gdlgWindow.UPDATE(1, "Sell-to Customer No.");
                gdlgWindow.UPDATE(2, "Ship-to Code");
                //
                gdlgWindow.UPDATE(3, "External Document No.");
                //
                CALCFIELDS("Qty. in Order Sheet", "Qty. Not Ordered");
                IF "Qty. Not Ordered" = 0 THEN
                    CurrReport.SKIP;

                //<JF06457AC>
                IF grecSalesSetup."Test Ord. Sht. Dup. Ext. Doc. ELA" THEN BEGIN

                    // 2. open sales headers

                    lrecSalesHeader.SETCURRENTKEY("Sell-to Customer No.", "External Document No.");

                    lrecSalesHeader.SETRANGE("Sell-to Customer No.", "Sell-to Customer No.");
                    lrecSalesHeader.SETRANGE("External Document No.", "External Document No.");
                    IF lrecSalesHeader.FINDFIRST THEN BEGIN
                        lrecSalesHeader.FIELDERROR("External Document No.");
                    END;

                    // 3. posted sales invoices

                    lrecSalesInvoice.SETCURRENTKEY("Sell-to Customer No.", "External Document No.");

                    lrecSalesInvoice.SETRANGE("Sell-to Customer No.", "Sell-to Customer No.");
                    lrecSalesInvoice.SETRANGE("External Document No.", "External Document No.");
                    IF lrecSalesInvoice.FINDFIRST THEN BEGIN
                        lrecSalesInvoice.FIELDERROR("External Document No.");
                    END;

                END;
                //</JF06457AC>

                //<JF09573AC>
                IF NOT grecDSDSetup."Override Loc. from Route Temp." THEN BEGIN
                    grecOrderSheetBatch.GET("Order Sheet Batch Name");
                    grecOrderSheetBatch.TESTFIELD("Location Code");
                    gcodBatchLocation := grecOrderSheetBatch."Location Code";
                END;
                //</JF09573AC>

                jfdoCreateSalesHeader;
            end;

            trigger OnPreDataItem()
            begin
                grecSalesSetup.GET;

                gdlgWindow.OPEN(JFText001 + ' \ ' + JFText002 + ' \ ' + ' \ ' + JFText004 + ' \ ' + JFText003);

                //<JF09573AC>
                IF gcduGranuleMgmt.jfTestTableLicensed(DATABASE::"DSD Setup") THEN BEGIN
                    IF grecDSDSetup.GET THEN;
                END;
                //</JF09573AC>
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(gdteShipmentDateOveride; gdteShipmentDateOveride)
                    {
                        Caption = 'Shipment Date Override';
                    }
                    field(gblnReleaseSO; gblnReleaseSO)
                    {
                        Caption = 'Release Sales Orders';
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        grecOrderSheetDetails: Record "Order Sheet Details";
        grecOrderSheetDetails2: Record "Order Sheet Details";
        grecOrderSheetItems: Record "Order Sheet Items";
        grecSalesHeader: Record "Sales Header";
        grecSalesLine: Record "Sales Line";
        gintNextLineNo: Integer;
        gdlgWindow: Dialog;
        JFText001: Label 'Customer #1###############';
        JFText002: Label 'Ship-to #2###############';
        JFText003: Label 'Item    #4###############';
        JFText004: Label 'Ext Doc. No.    #3###############';
        grecSalesSetup: Record "Sales & Receivables Setup";
        gdteShipmentDateOveride: Date;
        gblnReleaseSO: Boolean;
        gcduGranuleMgmt: Codeunit "Granule License Management";
        grecDSDSetup: Record "DSD Setup";
        grecOrderSheetBatch: Record "Order Sheet Batch";
        gcodBatchLocation: Code[10];
        gblnCommitPerOrder: Boolean;
        PrintFlag: Boolean;
        grepDelTicketBarCode: Report "Delivery Tkt UPC Barcode";

    [Scope('Internal')]
    procedure jfdoCreateSalesHeader()
    begin
        CLEAR(grecSalesHeader);

        grecSalesHeader."Document Type" := grecSalesHeader."Document Type"::Order;
        grecSalesHeader.INSERT(TRUE);

        //<JF00000AC>
        /*
        grecSalesHeader.VALIDATE("Order Date", WORKDATE);
        */
        grecSalesSetup.GET;
        IF NOT grecSalesSetup."Use Ship Date as Order Date ELA" THEN BEGIN
            grecSalesHeader.VALIDATE("Order Date", WORKDATE);
        END ELSE BEGIN
            //<JF4953DD>
            //-- Orignal Below
            /*
            grecSalesHeader.VALIDATE("Order Date", "Order Sheet Customers"."Shipment Date");
            */
            IF gdteShipmentDateOveride = 0D THEN BEGIN
                grecSalesHeader.VALIDATE("Order Date", "Order Sheet Customers"."Shipment Date");
            END ELSE BEGIN
                grecSalesHeader.VALIDATE("Order Date", gdteShipmentDateOveride);
            END;
            //</JF4953DD>
        END;
        //</JF00000AC>

        /*
        grecSalesHeader.VALIDATE("Posting Date", "Order Sheet Customers".GETRANGEMIN("Date Filter"));
        grecSalesHeader.VALIDATE("Shipment Date", "Order Sheet Customers".GETRANGEMIN("Date Filter"));
        */

        //<JF08476AC>
        // need to validate Customer No. before Shipment date to handle some DSD cases
        grecSalesHeader.VALIDATE("Sell-to Customer No.", "Order Sheet Customers"."Sell-to Customer No.");
        IF "Order Sheet Customers"."Ship-to Code" <> '' THEN
            grecSalesHeader.VALIDATE("Ship-to Code", "Order Sheet Customers"."Ship-to Code");
        grecSalesHeader.VALIDATE("External Document No.", "Order Sheet Customers"."External Document No.");
        //</JF08476AC>

        //<JF4953DD>
        //-- Orignal Below
        /*
        grecSalesHeader.VALIDATE("Posting Date", "Order Sheet Customers"."Shipment Date");
        grecSalesHeader.VALIDATE("Shipment Date", "Order Sheet Customers"."Shipment Date");
        */
        IF gdteShipmentDateOveride = 0D THEN BEGIN
            grecSalesHeader.VALIDATE("Posting Date", "Order Sheet Customers"."Shipment Date");
            grecSalesHeader.VALIDATE("Shipment Date", "Order Sheet Customers"."Shipment Date");
        END ELSE BEGIN
            grecSalesHeader.VALIDATE("Posting Date", gdteShipmentDateOveride);
            grecSalesHeader.VALIDATE("Shipment Date", gdteShipmentDateOveride);
        END;
        //</JF4953DD>

        //<JF08476AC> move this chunk earlier
        /*
        grecSalesHeader.VALIDATE("Sell-to Customer No.", "Order Sheet Customers"."Sell-to Customer No.");
        IF "Order Sheet Customers"."Ship-to Code" <> '' THEN
          grecSalesHeader.VALIDATE("Ship-to Code", "Order Sheet Customers"."Ship-to Code");
        grecSalesHeader.VALIDATE("External Document No.","Order Sheet Customers"."External Document No.");
        */
        //</JF08476AC>

        //<JF09573AC>
        IF gcodBatchLocation <> '' THEN BEGIN
            grecSalesHeader.VALIDATE("Location Code", gcodBatchLocation);
        END;
        //</JF09573AC>

        //<JF8943SHR>
        /*
        //<JF8797SHR>
        grecSalesHeader.VALIDATE("Payment Terms Code", "Order Sheet Customers"."Payment Terms Code");
        grecSalesHeader.VALIDATE("Due Date","Order Sheet Customers"."Due Date");
        //</JF8797SHR>
        */
        IF ("Order Sheet Customers"."Payment Terms Code" <> '') THEN BEGIN
            grecSalesHeader.VALIDATE("Payment Terms Code", "Order Sheet Customers"."Payment Terms Code");
        END;
        IF ("Order Sheet Customers"."Due Date" <> 0D) THEN BEGIN
            grecSalesHeader.VALIDATE("Due Date", "Order Sheet Customers"."Due Date");
        END;
        //</JF8943SHR>

        grecSalesHeader.MODIFY(TRUE);
        gintNextLineNo := 10000;

    end;

    [Scope('Internal')]
    procedure jfdoCreateSalesLine()
    var
        lrecSalesCommentLine: Record "Sales Comment Line";
    begin
        grecSalesLine.INIT;
        grecSalesLine."Document Type" := grecSalesHeader."Document Type";
        grecSalesLine."Document No." := grecSalesHeader."No.";
        grecSalesLine."Line No." := gintNextLineNo;
        grecSalesLine.Type := grecSalesLine.Type::Item;
        grecSalesLine.VALIDATE("No.", grecOrderSheetDetails."Item No.");
        IF grecOrderSheetDetails."Variant Code" <> '' THEN
            grecSalesLine.VALIDATE("Variant Code", grecOrderSheetDetails."Variant Code");
        IF grecOrderSheetDetails."Unit of Measure Code" <> '' THEN
            grecSalesLine.VALIDATE("Unit of Measure Code", grecOrderSheetDetails."Unit of Measure Code");

        grecSalesLine.VALIDATE("Requested Delivery Date", grecOrderSheetDetails."Requested Ship Date");
        grecSalesLine.VALIDATE("Planned Delivery Date", grecOrderSheetDetails."Requested Ship Date");
        //<JF4953DD>
        //-- Orignal Below
        /*
        grecSalesLine.VALIDATE("Shipment Date", grecOrderSheetDetails."Requested Ship Date");
        */
        IF gdteShipmentDateOveride = 0D THEN BEGIN
            grecSalesLine.VALIDATE("Shipment Date", grecOrderSheetDetails."Requested Ship Date");
        END ELSE BEGIN
            grecSalesLine.VALIDATE("Shipment Date", gdteShipmentDateOveride);
        END;
        //</JF4953DD>

        grecSalesLine.VALIDATE(Quantity, grecOrderSheetDetails.Quantity);

        //<JF12700AC>
        // if a Unit Price has been provided, use it
        IF grecOrderSheetDetails."Unit Price" <> 0 THEN BEGIN
            grecSalesLine.VALIDATE("Unit Price", grecOrderSheetDetails."Unit Price");
        END;

        IF grecOrderSheetDetails.Comment <> '' THEN BEGIN
            CLEAR(lrecSalesCommentLine);
            lrecSalesCommentLine.RESET;
            lrecSalesCommentLine.SETRANGE("Document Type", grecSalesHeader."Document Type");
            lrecSalesCommentLine.SETRANGE("No.", grecSalesHeader."No.");
            lrecSalesCommentLine.SETRANGE("Document Line No.", 0);
            lrecSalesCommentLine.SETRANGE("Line No.");
            lrecSalesCommentLine.SETFILTER(Comment, grecOrderSheetDetails.Comment); // add a header comment only
            IF NOT lrecSalesCommentLine.FINDFIRST THEN BEGIN
                lrecSalesCommentLine.SETRANGE(Comment);
                IF NOT lrecSalesCommentLine.FINDLAST THEN;
                lrecSalesCommentLine.INIT;
                lrecSalesCommentLine."Document Type" := grecSalesHeader."Document Type";
                lrecSalesCommentLine."No." := grecSalesHeader."No.";
                lrecSalesCommentLine."Document Line No." := 0; // add a header comment only
                lrecSalesCommentLine."Line No." := lrecSalesCommentLine."Line No." + 10000;
                lrecSalesCommentLine.Comment := grecOrderSheetDetails.Comment;
                lrecSalesCommentLine.INSERT(TRUE);
            END;
        END;
        //</JF12700AC>

        grecSalesLine.INSERT(TRUE);

        gintNextLineNo += 10000;

    end;

    [Scope('Internal')]
    procedure SetPrint(PrtFlg: Boolean)
    begin
        //<IB50343TZ>
        PrintFlag := PrtFlg;
        //</IB50343TZ>
    end;
}

