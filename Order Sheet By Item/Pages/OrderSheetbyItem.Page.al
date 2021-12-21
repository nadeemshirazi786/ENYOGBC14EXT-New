page 14228811 "Order Sheet by Item"
{
    // Copyright Axentia Solutions Corp.  1999-2010.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF4953DD - Order Sheet Items Additions
    //   20090820 - Added Fields to the Tablebox: (Left Side)
    //              * 60        "On Special"                    Boolean
    //              * 65        "Item Description"              Text 30
    //            - Added customer No. field to header and added/modified code throughout accordingly
    //   20090821 - Added code to aply customer No entered in form as part of defualt filders when running functions options
    //   20090824 - Added a couple of Currform Udates in the OnAfterValidate of filter field (form needs to refresh accordingly);
    // 
    // JF5918SHR
    //   20091102 - Added field to form
    //              * 66         "Item Description 2"
    // 
    // JF6603MG
    //   20091209 - Add new field
    //              * 67 Backordered Item
    // 
    // JF09161AC
    //   20100909 - transformed from Page 23019135
    // 
    // IB50343TZ 20151104 - modified action to "create and Print" option

    Caption = 'Order Sheet by Item';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ApplicationArea = All;
    UsageCategory = Documents;
    PageType = Card;
    SaveValues = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(gcodBatchName; gcodBatchName)
                {
                    Caption = 'Order Sheet Batch Name';
                    TableRelation = "Order Sheet Batch".Name;

                    trigger OnValidate()
                    begin
                        refreshSubform;
                    end;
                }
                field(gcodCustomerNo; gcodCustomerNo)
                {
                    Caption = 'Customer No.';
                    TableRelation = Customer;

                    trigger OnValidate()
                    var
                        lrecOrderSheetCust: Record "Order Sheet Customers";
                        lintLineNo: Integer;
                    begin
                        //<JF4953DD>
                        IF gcodCustomerNo <> '' THEN BEGIN
                            //-- Lok for existing first
                            lrecOrderSheetCust.SETRANGE("Order Sheet Batch Name", gcodBatchName);
                            lrecOrderSheetCust.SETRANGE("Sell-to Customer No.", gcodCustomerNo);

                            IF NOT lrecOrderSheetCust.FINDFIRST THEN BEGIN
                                lrecOrderSheetCust.SETRANGE("Sell-to Customer No.");  //-- clear filter

                                IF lrecOrderSheetCust.FINDLAST THEN
                                    lintLineNo := lrecOrderSheetCust."Line No." + 1000
                                ELSE
                                    lintLineNo := 10000;

                                lrecOrderSheetCust.INIT;

                                lrecOrderSheetCust."Order Sheet Batch Name" := gcodBatchName;
                                lrecOrderSheetCust."Line No." := lintLineNo;
                                lrecOrderSheetCust.VALIDATE("Sell-to Customer No.", gcodCustomerNo);
                                lrecOrderSheetCust.INSERT;
                            END;
                        END;
                        //</JF4953DD>>

                        refreshSubform;
                    end;
                }
                field(gtxtDateFilter; gtxtDateFilter)
                {
                    Caption = 'Date Filter';

                    trigger OnValidate()
                    var
                        ApplicationManagement: Codeunit TextManagement;
                    begin
                        IF ApplicationManagement.MakeDateFilter(gtxtDateFilter) = 0 THEN;
                        grecOrderSheetItem.SETFILTER("Date Filter", gtxtDateFilter);
                        gtxtDateFilter := grecOrderSheetItem.GETFILTER("Date Filter");
                        refreshSubform;
                    end;
                }
                field(gtxtLocationFilter; gtxtLocationFilter)
                {
                    Caption = 'Location Filter';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        lfrmLocationList: Page "Location List";
                    begin
                        lfrmLocationList.LOOKUPMODE(TRUE);
                        IF NOT (lfrmLocationList.RUNMODAL = ACTION::LookupOK) THEN
                            EXIT(FALSE)
                        ELSE
                            Text := lfrmLocationList.GetSelectionFilter;
                        EXIT(TRUE);
                    end;

                    trigger OnValidate()
                    begin
                        refreshSubform;
                    end;
                }
                field(goptItemDisplay; goptItemDisplay)
                {
                    Caption = 'Column Heading Format';

                    trigger OnValidate()
                    begin
                        MATRIX_GenerateColumnCaptions(MATRIX_SetWanted::Same);
                        UpdateMatrixSubform();
                    end;
                }
            }
            part(MatrixForm; "Order Sheet By Item Matrix")
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
                action("Create Sales Orders")
                {
                    Caption = 'Create Sales Orders';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        lrecOrderSheetCustomers: Record "Order Sheet Customers";
                        lrepMakeOrders: Report "Order Sheet - Make Orders";
                    begin
                        lrecOrderSheetCustomers.COPY(MatrixRecord);
                        //<IB50343TZ>
                        Selection := STRMENU('Create Orders,Create and Print Orders', 2);
                        IF Selection = 0 THEN
                            EXIT;
                        lrepMakeOrders.SetPrint(Selection = 2);
                        lrepMakeOrders.SETTABLEVIEW(lrecOrderSheetCustomers);
                        lrepMakeOrders.RUN;

                        //</IB50343TZ>
                    end;
                }
                action("Copy to Forecast")
                {
                    Caption = 'Copy to Forecast';
                    Image = CopyForecast;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        lrecOrderSheetCustomers: Record "Order Sheet Customers";
                    begin
                        lrecOrderSheetCustomers.COPY(MatrixRecord);

                        REPORT.RUN(REPORT::"Order Sheet - Copy to Forecast", TRUE, FALSE, lrecOrderSheetCustomers);
                    end;
                }
            }
            action("Previous Set")
            {
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Set';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next;
                begin
                    //SetPoints(Direction::Backward);
                    MATRIX_GenerateColumnCaptions(Step::Previous);
                    UpdateMatrixSubform();
                end;
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
                    //SetPoints(Direction::Backward);
                    MATRIX_GenerateColumnCaptions(Step::PreviousColumn);
                    UpdateMatrixSubform();
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
                    //SetPoints(Direction::Forward);
                    MATRIX_GenerateColumnCaptions(Step::NextColumn);
                    UpdateMatrixSubform();
                end;
            }
            action("Next Set")
            {
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Set';

                trigger OnAction()
                var
                    Step: Option First,Previous,Same,Next;
                begin
                    //SetPoints(Direction::Forward);
                    MATRIX_GenerateColumnCaptions(Step::Next);
                    UpdateMatrixSubform();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        //<JF4953DD>
        grecSRSetup.GET;
        //</JF4953DD>

        MaximumNoOfCaptions := ARRAYLEN(MATRIX_CaptionSet);
        MATRIX_GenerateColumnCaptions(MATRIX_SetWanted::Initial);
        UpdateMatrixSubform();
    end;

    var
        gcodBatchName: Code[10];
        goptItemDisplay: Option "Customer No. + Ship-To Code","Customer Name + Ship-To Code","Customer No. + Ship-To Name","Customer No.","Customer Name";
        grecOrderSheetItem: Record "Order Sheet Items" temporary;
        grecOrderSheetCustomers: Record "Order Sheet Customers";
        gblnShowDataOnly: Boolean;
        gcodCustomerNo: Code[20];
        gtxtDateFilter: Text[250];
        gtxtLocationFilter: Text[250];
        SalesInfoPaneMgt: Codeunit "Sales Info-Pane Management";
        grecSRSetup: Record "Sales & Receivables Setup";
        MatrixRecords: array[32] of Record "Order Sheet Customers";
        MatrixRecord: Record "Order Sheet Customers";
        MATRIX_CaptionSet: array[32] of Text[1024];
        MATRIX_ColumnSet: Text[1024];
        FirstColumn: Text[1024];
        LastColumn: Text[1024];
        MATRIX_CaptionFieldNo: Integer;
        MATRIX_PrimaryKeyFirstCaptionI: Text[1024];
        MatrixHeader: Text[250];
        ShowColumnName: Boolean;
        MatrixMgm: Codeunit "Matrix Management";
        MaximumNoOfCaptions: Integer;
        PrimaryKeyFirstCaptionInCurrSe: Text[1024];
        ColumnSet: Text[1024];
        MATRIX_CurrSetLength: Integer;
        MATRIX_SetWanted: Option Initial,Previous,Same,Next,PreviousColumn,NextColumn;
        Selection: Integer;

    [Scope('Internal')]
    procedure MATRIX_GenerateColumnCaptions(SetWanted: Option Initial,Previous,Same,Next)
    var
        RecRef: RecordRef;
        CurrentMatrixRecordOrdinal: Integer;
        lrecShipTo: Record "Ship-to Address";
    begin
        grecOrderSheetItem.SETFILTER("Date Filter", gtxtDateFilter);

        grecOrderSheetItem.FILTERGROUP(2);
        grecOrderSheetItem.SETRANGE("Order Sheet Batch Name", gcodBatchName);
        CurrPage.MatrixForm.PAGE.SETTABLEVIEW(grecOrderSheetItem);
        grecOrderSheetItem.FILTERGROUP(0);

        CurrPage.MatrixForm.PAGE.SetDateFilter(gtxtDateFilter);

        MatrixRecord.SETRANGE("Order Sheet Batch Name", gcodBatchName);

        IF grecSRSetup."Use Ord Sht Item CustNo Fltr ELA" = TRUE THEN BEGIN
            IF gcodCustomerNo = '' THEN BEGIN
                MatrixRecord.SETRANGE("Ship-to Code");
            END;
            MatrixRecord.SETRANGE("Sell-to Customer No.", gcodCustomerNo);
        END ELSE BEGIN
            IF gcodCustomerNo = '' THEN BEGIN
                MatrixRecord.SETRANGE("Sell-to Customer No.");
                MatrixRecord.SETRANGE("Ship-to Code");
            END ELSE BEGIN
                MatrixRecord.SETRANGE("Sell-to Customer No.", gcodCustomerNo);
            END;
        END;

        MatrixRecord.SETFILTER("Date Filter", gtxtDateFilter);

        CLEAR(MATRIX_CaptionSet);
        CLEAR(MatrixRecords);
        CurrentMatrixRecordOrdinal := 1;

        RecRef.GETTABLE(MatrixRecord);
        RecRef.SETTABLE(MatrixRecord);

        CASE goptItemDisplay OF
            goptItemDisplay::"Customer Name + Ship-To Code":
                BEGIN
                    SetMultiFieldColumnCaption(12, 11, 0);
                END;
            goptItemDisplay::"Customer No. + Ship-To Code":
                BEGIN
                    SetMultiFieldColumnCaption(10, 11, 0);
                END;
            goptItemDisplay::"Customer No. + Ship-To Name":
                BEGIN
                    SetMultiFieldColumnCaption(10, 23019003, 0);
                END;
            goptItemDisplay::"Customer No.":
                BEGIN
                    SetMultiFieldColumnCaption(10, 0, 0);
                END;
            goptItemDisplay::"Customer Name":
                BEGIN
                    SetMultiFieldColumnCaption(12, 0, 0);
                END;
        END;

        MatrixMgm.GenerateMatrixData(RecRef, SetWanted, MaximumNoOfCaptions, MATRIX_CaptionFieldNo, PrimaryKeyFirstCaptionInCurrSe,
                        MATRIX_CaptionSet, MATRIX_ColumnSet, MATRIX_CurrSetLength);

        IF MATRIX_CurrSetLength > 0 THEN
            MatrixRecord.SETPOSITION(PrimaryKeyFirstCaptionInCurrSe);

        IF NOT MatrixRecord.FIND('=') THEN BEGIN
            EXIT;
        END;

        REPEAT
            MatrixRecords[CurrentMatrixRecordOrdinal].COPY(MatrixRecord);
            CurrentMatrixRecordOrdinal := CurrentMatrixRecordOrdinal + 1;
        UNTIL (CurrentMatrixRecordOrdinal = ARRAYLEN(MatrixRecords)) OR (MatrixRecord.NEXT <> 1);
    end;

    [Scope('Internal')]
    procedure UpdateMatrixSubform()
    begin
        CurrPage.MatrixForm.PAGE.Load(MATRIX_CaptionSet, MatrixRecords);
    end;

    local procedure refreshSubform()
    begin
        MATRIX_GenerateColumnCaptions(MATRIX_SetWanted::Initial);
        UpdateMatrixSubform();
    end;

    procedure SetMultiFieldColumnCaption(pintFieldNo1: Integer; pintFieldNo2: Integer; pintFieldNo3: Integer)
    var
        gblnUseMultiFieldColumnCaption: Boolean;
        gintCaptionFieldNo1: Integer;
        gintCaptionFieldNo2: Integer;
        gintCaptionFieldNo3: Integer;
    begin

        gblnUseMultiFieldColumnCaption := TRUE;
        gintCaptionFieldNo1 := pintFieldNo1;
        gintCaptionFieldNo2 := pintFieldNo2;
        gintCaptionFieldNo3 := pintFieldNo3;
    end;
}

