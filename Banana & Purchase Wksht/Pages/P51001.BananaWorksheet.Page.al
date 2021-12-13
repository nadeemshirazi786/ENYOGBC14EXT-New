page 51001 "Banana Worksheet"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    ApplicationArea = all;
    UsageCategory = Documents;
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Date; Date)
                {
                    Caption = 'Date';

                    trigger OnValidate()
                    begin
                        SetDateAndLocation(Date, gcodLocationCode);
                    end;
                }
                field(gcodLocationCode; gcodLocationCode)
                {
                    Caption = 'Location Code';
                    TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

                    trigger OnValidate()
                    begin
                        SetDateAndLocation(Date, gcodLocationCode);
                    end;
                }
            }
            part(Matrix; "Banana Worksheet Matrix")
            {
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                action("Calculate Shipment Date from Route Template")
                {
                    Caption = 'Calculate Shipment Date from Route Template';
                    Image = CalculateCalendar;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin

                        jfCalcRouteTemplateDetails;

                    end;
                }
                action("Create Sales Orders")
                {
                    Caption = 'Create Sales Orders';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        CreateOrders: Report "Create Banana Orders";
                        Selection: Integer;
                    begin
                        Selection := StrMenu('Create Orders,Create and Print Orders', 2);
                        if Selection = 0 then
                            exit;
                        CreateOrders.SetDate(Date, gcodLocationCode);
                        CreateOrders.SetPrint(Selection = 2);
                        CreateOrders.jfSetRelease(true);
                        CreateOrders.RunModal;
                        Clear(BananaWS);
                        BananaWS.SetRange(Date, Date);
                        BananaWS.DeleteAll;

                        SetDateAndLocation(Date, gcodLocationCode);
                    end;
                }
            }
            action("Previous Column")
            {
                Caption = 'Previous Column';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next,PreviousColumn,NextColumn;
                begin
                    jfSetColumns(Step::PreviousColumn);
                end;
            }
            action("Next Column")
            {
                Caption = 'Next Column';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next,PreviousColumn,NextColumn;
                begin
                    jfSetColumns(Step::NextColumn);
                end;
            }
            group("&Print")
            {
                Caption = '&Print';
                Image = Print;
                action("Banana Orders")
                {
                    Caption = 'Banana Orders';
                    Ellipsis = true;
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    var
                        BananaRpt: Report "Banana Orders";
                    begin
                        BananaRpt.SetShipDate(Date);
                        BananaRpt.RunModal;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin

        Clear(gcodLocationCode);
        Date := WorkDate + 1;
        SetDateAndLocation(Date, gcodLocationCode);

        MatrixRecord.SetRange(Input, true);
    end;

    var
        BananaWS: Record "Banana Worksheet";
        Date: Date;
        PONumber: Code[20];
        gcodLocationCode: Code[20];
        "------------": Integer;
        MatrixRecord: Record "Banana Worksheet Column";
        MatrixRecords: array[32] of Record "Banana Worksheet Column";
        MatrixRecordRef: RecordRef;
        MatrixSetWanted: Option Initial,Previous,Same,Next;
        MatrixColumnCaptions: array[32] of Text[1024];
        MatrixCaptionRange: Text[1024];
        MatrixPKFirstRecInCurrSet: Text[1024];
        MatrixCurrSetLength: Integer;
        grecMatrixRecords_Sorted: Record "Banana Worksheet Column";

    [Scope('Internal')]
    procedure SetDateAndLocation(Date: Date; pcodLocationCode: Code[20])
    var
        ItemPref: Record "Banana Worksheet Column";
        LineNo: Integer;
    begin
        BananaWS.Reset;
        BananaWS.SetRange("Customer No.", '');
        BananaWS.SetRange(Date, 0D, Date - 1);
        BananaWS.SetRange("Location Code", pcodLocationCode);
        BananaWS.DeleteAll;
        BananaWS.Reset;

        if BananaWS.Find('+') then
            LineNo := BananaWS."Line No."
        else
            LineNo := 0;

        ItemPref.SetRange(Input, false);
        ItemPref.SetRange(Order, true);
        if ItemPref.Find('-') then begin
            BananaWS.SetCurrentKey("Customer No.", "Ship-to Code", "Item No.", "Variant Code", "Location Code", "Preference Code", Date);
            BananaWS.SetRange("Customer No.", '');
            BananaWS.SetRange("Ship-to Code", '');
            BananaWS.SetRange(Date, Date);
            BananaWS.SetRange("Location Code", pcodLocationCode);
            repeat
                BananaWS.SetRange("Item No.", ItemPref."Item No.");
                BananaWS.SetRange("Variant Code", ItemPref."Variant Code");
                BananaWS.SetRange("Location Code", pcodLocationCode);
                BananaWS.SetRange("Preference Code", ItemPref."Banana Preference Code");
                if not BananaWS.Find('-') then begin
                    LineNo += 1;
                    BananaWS."Line No." := LineNo;
                    BananaWS."Customer No." := '';
                    BananaWS."Ship-to Code" := '';
                    BananaWS."Item No." := ItemPref."Item No.";
                    BananaWS."Variant Code" := ItemPref."Variant Code";
                    BananaWS."Location Code" := pcodLocationCode;
                    BananaWS."Preference Code" := ItemPref."Banana Preference Code";
                    BananaWS.Date := Date;
                    BananaWS.Quantity := 0;
                    BananaWS.Insert;
                end;
            until ItemPref.Next = 0;
        end;
        jfSetColumns(MatrixSetWanted::Initial);
    end;

    [Scope('Internal')]
    procedure jfCalcRouteTemplateDetails()
    var
        lrecBananaWkshCust: Record "Banana Worksheet Customers";
        lrecDSDSetup: Record "DSD Setup";
        lcodBatchLocation: Code[10];
        lcodUnassignedLocation: Code[10];
        lcodTemplateLocation: Code[10];
        lint: Integer;
        ltxtDateExpr: Text[3];
        ldatTryShip: Date;
        lrecSalesOrder: Record "Sales Header";
        ldatUse: Date;
        lcduRouteTemplateMgmt: Codeunit BananaWrkshtCustomFunctions;
        lrecRouteStopDetail: Record "DSD Route Stop Tmplt. Detail";
    begin
        CurrPage.Matrix.PAGE.jfCopyRec(lrecBananaWkshCust);
        if lrecBananaWkshCust.FindSet(true, false) then begin
            lrecDSDSetup.Get;
            lrecDSDSetup.TestField("Orders Use Template Route");
            //lcodUnassignedLocation := lrecDSDSetup."Unassigned Location Code";
            if not lrecDSDSetup."Override Loc. from Route Temp." then begin
                lcodBatchLocation := lrecBananaWkshCust."Location Code";
            end;
            repeat
                lrecBananaWkshCust.CalcFields("Direct Store Delivery");
                if lrecBananaWkshCust."Direct Store Delivery" then begin
                    lint := 0;
                    lcodTemplateLocation := lcodUnassignedLocation;
                    ldatUse := 0D;
                    while ((lint < 8) and (ldatUse = 0D)) do begin
                        ltxtDateExpr := '+' + Format(lint) + 'D';
                        ldatTryShip := CalcDate(ltxtDateExpr, Date);
                        lrecSalesOrder.SetCurrentKey("Shipment Date",
                                                "Location Code", "Sell-to Customer No.");
                        lrecSalesOrder.SetRange("Shipment Date", ldatTryShip);
                        if not lrecDSDSetup."Override Loc. from Route Temp." then begin
                            lrecSalesOrder.SetFilter("Location Code", '=%1', lcodBatchLocation);
                        end else begin
                            lrecSalesOrder.SetRange("Location Code");
                        end;
                        lrecSalesOrder.SetRange("Sell-to Customer No.", lrecBananaWkshCust."Customer No.");
                        lrecSalesOrder.SetFilter("Ship-to Code", '=%1', lrecBananaWkshCust."Ship-to Code");
                        lrecSalesOrder.SetRange("Document Type", lrecSalesOrder."Document Type"::Order);
                        if lrecSalesOrder.FindFirst then begin
                            if lrecDSDSetup."Override Loc. from Route Temp." then begin
                                lcodTemplateLocation := lrecSalesOrder."Location Code";
                            end else begin
                                lcodTemplateLocation := lrecSalesOrder."Supply Chain Group Code ELA";
                            end;
                            ldatUse := lrecSalesOrder."Shipment Date";
                        end else begin

                            if lcduRouteTemplateMgmt.FindDSDTemplateStop(lrecRouteStopDetail,
                                                                         lrecBananaWkshCust."Customer No.",
                                                                         ldatTryShip,
                                                                         lcodBatchLocation,
                                                                         lrecBananaWkshCust."Ship-to Code",
                                                                         false
                                                                         )
                            then begin
                                if (lrecRouteStopDetail.Route <> '')
                                and (lrecRouteStopDetail.Route <> lcodUnassignedLocation) then begin
                                    ldatUse := ldatTryShip;
                                    lcodTemplateLocation := lrecRouteStopDetail.Route;
                                end;
                            end;

                        end;

                        lint += 1;
                    end;
                    if ldatUse = 0D then begin
                        ldatUse := WorkDate;
                        lcodTemplateLocation := lcodUnassignedLocation;
                    end;
                    lrecBananaWkshCust."Requested Shipment Date" := ldatUse;
                    lrecBananaWkshCust."Order Template Location" := lcodTemplateLocation;
                    lrecBananaWkshCust.Modify;
                end;
            until lrecBananaWkshCust.Next = 0;
        end;

    end;

    [Scope('Internal')]
    procedure jfSetColumns(SetWanted: Option Initial,Previous,Same,Next)
    var
        i: Integer;
        MatrixMgt: Codeunit "Matrix Management";
        CaptionFieldNo: Integer;
        CurrentMatrixRecordOrdinal: Integer;
    begin
        Clear(MatrixColumnCaptions);
        Clear(MatrixRecords);
        CurrentMatrixRecordOrdinal := 1;
        for i := 1 to ArrayLen(MatrixRecords) do begin
        end;

        MatrixRecordRef.GetTable(MatrixRecord);
        MatrixRecordRef.SetTable(MatrixRecord);

        CaptionFieldNo := MatrixRecord.FieldNo("Column Heading");

        MatrixRecordRef.CurrentKeyIndex(2);

        MatrixMgt.GenerateMatrixData(MatrixRecordRef, SetWanted, ArrayLen(MatrixRecords), CaptionFieldNo, MatrixPKFirstRecInCurrSet,
          MatrixColumnCaptions, MatrixCaptionRange, MatrixCurrSetLength);

        if MatrixCurrSetLength > 0 then begin
            MatrixRecord.SetPosition(MatrixPKFirstRecInCurrSet);
            MatrixRecord.Find;
            grecMatrixRecords_Sorted.Copy(MatrixRecord);
            grecMatrixRecords_Sorted.SetCurrentKey(Sequence);
            repeat
                MatrixRecords[CurrentMatrixRecordOrdinal].Copy(grecMatrixRecords_Sorted);
                CurrentMatrixRecordOrdinal := CurrentMatrixRecordOrdinal + 1;
            until (CurrentMatrixRecordOrdinal > MatrixCurrSetLength) or (grecMatrixRecords_Sorted.Next <> 1);
        end;

        jfSetMatrix;
    end;

    [Scope('Internal')]
    procedure jfSetMatrix()
    begin
        CurrPage.Matrix.PAGE.Load(
                                  MatrixColumnCaptions,
                                  MatrixRecords,
                                  gcodLocationCode,
                                  Date,
                                  grecMatrixRecords_Sorted.GetView
                                  );
        CurrPage.Update(false);
    end;
}

