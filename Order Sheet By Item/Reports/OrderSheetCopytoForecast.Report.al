report 14228812 "Order Sheet - Copy to Forecast"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // //<JF00042DO>
    // 
    // JF09573AC
    //   20101004 - add jfSetLocationCode accessor

    Caption = 'Order Sheet - Copy to Forecast';
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

                    //grecOrderSheetDetails.SETRANGE("Ship-to Code", "Order Sheet Customers"."Ship-to Code");

                    "Order Sheet Customers".COPYFILTER("Date Filter", grecOrderSheetDetails."Requested Ship Date");
                    grecOrderSheetDetails.SETRANGE("Item No.", "Order Sheet Items"."Item No.");
                    grecOrderSheetDetails.SETRANGE("Variant Code", "Order Sheet Items"."Variant Code");
                    grecOrderSheetDetails.SETRANGE("Unit of Measure Code", "Order Sheet Items"."Unit of Measure Code");

                    IF grecOrderSheetDetails.FIND('-') THEN BEGIN
                        gdlgWindow.UPDATE(3, grecOrderSheetDetails."Item No." + ', ' + grecOrderSheetDetails."Unit of Measure Code");
                        REPEAT
                            grecOrderSheetDetails.SETRANGE("Requested Ship Date", grecOrderSheetDetails."Requested Ship Date");
                            grecOrderSheetDetails.CALCSUMS(Quantity);

                            jfdoCreateForecastEntry;

                            grecOrderSheetDetails.FIND('+');
                            "Order Sheet Customers".COPYFILTER("Date Filter", grecOrderSheetDetails."Requested Ship Date");
                        UNTIL grecOrderSheetDetails.NEXT = 0;
                    END;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                gdlgWindow.UPDATE(1, "Sell-to Customer No.");
                gdlgWindow.UPDATE(2, "Ship-to Code");
                CALCFIELDS("Qty. in Order Sheet");
                IF "Qty. in Order Sheet" = 0 THEN
                    CurrReport.SKIP;
            end;

            trigger OnPreDataItem()
            begin
                gdlgWindow.OPEN(JFText001 + ' \ ' + JFText002 + ' \ ' + JFText003);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(gcodProdForecast; gcodProdForecast)
                    {
                        Caption = 'Production Forecast Name';
                        TableRelation = "Production Forecast Name";
                    }
                    field(gcodLocation; gcodLocation)
                    {
                        Caption = 'Copy to Location';
                        TableRelation = Location;
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
        grecOrderSheetItems: Record "Order Sheet Items";
        grecItem: Record Item;
        gintNextLineNo: Integer;
        gdlgWindow: Dialog;
        JFText001: Label 'Customer #1###############';
        JFText002: Label 'Ship-to #2###############';
        JFText003: Label 'Item    #3###############';
        gcodProdForecast: Code[10];
        gcodLocation: Code[10];
        gintNextEntryNo: Integer;

    [Scope('Internal')]
    procedure jfdoCreateForecastEntry()
    var
        lcduUOMMgt: Codeunit "Unit of Measure Management";
    begin

        grecItem.RESET;
        grecItem.GET("Order Sheet Items"."Item No.");
        grecItem.SETRANGE("Production Forecast Name", gcodProdForecast);
        grecItem.SETRANGE("Date Filter", grecOrderSheetDetails."Requested Ship Date");
        grecItem.SETRANGE("Customer No. Filter ELA", "Order Sheet Customers"."Sell-to Customer No.");
        grecItem.SETRANGE("Variant Filter", "Order Sheet Items"."Variant Code");
        grecItem.SETRANGE("Location Filter", gcodLocation);


        grecItem.VALIDATE("Prod. Forecast Quantity (Base)",
          ROUND(
            grecOrderSheetDetails.Quantity *
            lcduUOMMgt.GetQtyPerUnitOfMeasure(grecItem, grecOrderSheetItems."Unit of Measure Code"), 0.00001));
    end;

    [Scope('Internal')]
    procedure jfSetLocationCode(pcodLocation: Code[10])
    begin
        gcodLocation := pcodLocation;
    end;
}

