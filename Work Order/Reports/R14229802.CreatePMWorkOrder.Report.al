report 14229802 "Create PM Work Order ELA"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("PM Work Order Matrix"; "PM Work Order Matrix")
        {
            DataItemTableView = SORTING (Type, "No.", "PM Procedure");
            RequestFilterFields = Type, "No.", "PM Procedure";

            trigger OnAfterGetRecord()
            var
                lrecTMPQualityAuditHeader: Record Table23019260;
                ldteNextAuditDate: Date;
            begin
                //Update Dialog
                gintCounter := gintCounter + 1;
                gdlgWindow.Update(1, Round(gintCounter / gintCount * 10000, 1));

                Clear(ldteNextAuditDate);
                if "Last Work Order Date" <> 0D then begin
                    ldteNextAuditDate := CalcDate("Work Order Freq.", "Last Work Order Date");
                end;
                if (gdteDate >= ldteNextAuditDate) then begin
                    lrecTMPQualityAuditHeader.INIT;
                    lrecTMPQualityAuditHeader.Type := "PM Work Order Matrix".Type;
                    lrecTMPQualityAuditHeader."No." := "PM Work Order Matrix"."No.";
                    lrecTMPQualityAuditHeader."PM Procedure Code" := "PM Procedure";
                    lrecTMPQualityAuditHeader.jfdoCreatePMWO;
                    "PM Work Order Matrix"."Last Work Order Date" := gdteDate;
                    "PM Work Order Matrix".Modify;
                end;
            end;

            trigger OnPostDataItem()
            begin
                gdlgWindow.Close;
            end;

            trigger OnPreDataItem()
            begin
                if gdteDate = 0D then begin
                    Error(gcon0001);
                end;

                Clear(gintCount);
                Clear(gintCounter);

                gdlgWindow.Open(gcon0002);
                gintCount := Count;
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
                    field("Date Formula"; gdteDate)
                    {
                        Caption = 'Date ';

                        trigger OnValidate()
                        begin
                            if gdteDate = 0D then begin
                                Error(gcon0001);
                            end;
                        end;
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

    trigger OnPreReport()
    begin
        if gdteDate = 0D then begin
            Error(gcon0001);
        end;
    end;

    var
        gdteDate: Date;
        gdlgWindow: Dialog;
        gcon0001: Label 'Date Formula can''t be blank.';
        gcon0002: Label 'Creating PM Work Order @1@@@@@@@@@@@@@';
        gintCount: Integer;
        gintCounter: Integer;
}

