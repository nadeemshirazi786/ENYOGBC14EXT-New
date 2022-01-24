report 14229803 "Suggest PM Work Orders ELA"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem("PM Procedure Header"; "PM Procedure Header ELA")
        {
            RequestFilterFields = "PM Group Code", "PM Scheduling Type", "Code";

            trigger OnAfterGetRecord()
            var
                ldteNextAuditDate: Date;
            begin
                //Update Dialog
                gintCounter := gintCounter + 1;
                gdlgWindow.Update(1, Round(gintCounter / gintCount * 10000, 1));

                if "Version No." <> gcduPMMgt.GetActiveVersion(Code) then
                    CurrReport.Skip;

                if Status <> Status::Certified then
                    CurrReport.Skip;

                //Should this PM Procedure have a Work Order Generated?
                gblnCreateWorkOrder := false;
                ldteNextAuditDate := 0D;
                CalcFields("Last Work Order Date");

                if "Schedule at %" = 0 then
                    "Schedule at %" := 100;

                if not "Multiple Calc. Methods" then begin
                    case "PM Scheduling Type" of

                        "PM Scheduling Type"::Calendar:
                            begin
                                if "Last Work Order Date" <> 0D then
                                    ldteNextAuditDate := CalcDate("Work Order Freq.", "Last Work Order Date")
                                else
                                    ldteNextAuditDate := 0D;
                                if ((ldteNextAuditDate >= gdteStartDate) and (ldteNextAuditDate <= gdteEndDate)) or
                                   (ldteNextAuditDate = 0D)
                                then
                                    gblnCreateWorkOrder := true;

                            end;

                        "PM Scheduling Type"::Cycles:
                            begin
                                jfdoCalcCycles;

                                if "Schedule at %" / 100 * "Evaluation Qty." <= (Cycles - "Cycles at Last Work Order") then
                                    gblnCreateWorkOrder := true;
                            end;

                        "PM Scheduling Type"::"Qty. Produced":
                            begin
                                jfdoCalcQtyProduced;
                                if "Schedule at %" / 100 * "Evaluation Qty." <= "Qty. Produced" then
                                    gblnCreateWorkOrder := true;
                            end;
                        "PM Scheduling Type"::"Run Time":
                            begin
                                jfdoCalcQtyProduced;
                                gdecTest := "Schedule at %" / 100 * "Evaluation Qty.";
                                if "Schedule at %" / 100 * "Evaluation Qty." <= "Capacity Qty." then
                                    gblnCreateWorkOrder := true;
                            end;
                        "PM Scheduling Type"::"Stop Time":
                            begin
                                jfdoCalcQtyProduced;
                                //<JF43819SHR>
                                gdecTest := "Schedule at %" / 100 * "Evaluation Qty.";
                                if "Schedule at %" / 100 * "Evaluation Qty." <= "Stop Time" then
                                    gblnCreateWorkOrder := true;
                                //</JF43819SHR>

                            end;
                    end;
                end else begin
                    grecPMCalcMethod.SetRange("PM Procedure Code", Code);
                    grecPMCalcMethod.SetRange("Version No.", "Version No.");
                    if grecPMCalcMethod.Find('-') then
                        repeat

                            case grecPMCalcMethod."PM Scheduling Type" of

                                grecPMCalcMethod."PM Scheduling Type"::Calendar:
                                    begin
                                        if "Last Work Order Date" <> 0D then
                                            ldteNextAuditDate := CalcDate(grecPMCalcMethod."Work Order Freq.", "Last Work Order Date")
                                        else
                                            ldteNextAuditDate := 0D;
                                        if ((ldteNextAuditDate >= gdteStartDate) and (ldteNextAuditDate <= gdteEndDate)) or
                                           (ldteNextAuditDate = 0D)
                                        then
                                            gblnCreateWorkOrder := true;

                                    end;

                                grecPMCalcMethod."PM Scheduling Type"::Cycles:
                                    begin
                                        jfdoCalcCycles;

                                        if grecPMCalcMethod."Schedule at %" / 100 * grecPMCalcMethod."Evaluation Qty." <=
                                         (grecPMCalcMethod.Cycles - grecPMCalcMethod."Cycles at Last Work Order") then
                                            gblnCreateWorkOrder := true;
                                    end;

                                grecPMCalcMethod."PM Scheduling Type"::"Qty. Produced":
                                    begin
                                        jfdoCalcQtyProduced;
                                        if grecPMCalcMethod."Schedule at %" / 100 * grecPMCalcMethod."Evaluation Qty." <= grecPMCalcMethod."Qty. Produced" then
                                            gblnCreateWorkOrder := true;
                                    end;

                                grecPMCalcMethod."PM Scheduling Type"::"Run Time":
                                    begin
                                        jfdoCalcQtyProduced;
                                        gdecTest := grecPMCalcMethod."Schedule at %" / 100 * grecPMCalcMethod."Evaluation Qty.";
                                        if grecPMCalcMethod."Schedule at %" / 100 * grecPMCalcMethod."Evaluation Qty." <= grecPMCalcMethod."Capacity Qty." then
                                            gblnCreateWorkOrder := true;
                                    end;

                                grecPMCalcMethod."PM Scheduling Type"::"Stop Time":
                                    begin
                                        jfdoCalcQtyProduced;
                                        //<JF43819SHR>
                                        gdecTest := "Schedule at %" / 100 * "Evaluation Qty.";
                                        if "Schedule at %" / 100 * "Evaluation Qty." <= "Stop Time" then
                                            gblnCreateWorkOrder := true;
                                        //</JF43819SHR>

                                    end;
                            end;
                            if not gblnCreateWorkOrder then
                                gblnExit := grecPMCalcMethod.Next = 0;
                        until gblnCreateWorkOrder or (gblnExit);
                end;


                if gblnCreateWorkOrder then begin
                    grecPMPlanWksht."Worksheet Batch Name" := gcodPMPlanWksht;
                    grecPMPlanWksht."Line No." := gintNextLineNo;
                    gintNextLineNo += 10000;
                    grecPMPlanWksht."PM Procedure Code" := Code;
                    grecPMPlanWksht."Version No." := gcduPMMgt.GetActiveVersion(Code);
                    grecPMPlanWksht.SetDefaults;

                    if "Multiple Calc. Methods" then begin
                        grecPMPlanWksht."Work Order Freq." := grecPMCalcMethod."Work Order Freq.";
                        grecPMPlanWksht."PM Scheduling Type" := grecPMCalcMethod."PM Scheduling Type";
                        grecPMPlanWksht."Evaluation Qty." := grecPMCalcMethod."Evaluation Qty.";
                        grecPMPlanWksht."Schedule at %" := grecPMCalcMethod."Schedule at %";
                    end;

                    if ldteNextAuditDate <> 0D then
                        grecPMPlanWksht."Work Order Date" := ldteNextAuditDate
                    else
                        grecPMPlanWksht."Work Order Date" := gdteWorkOrderDate;

                    grecPMPlanWksht.Insert;

                end;
            end;

            trigger OnPostDataItem()
            begin
                gdlgWindow.Close;
            end;

            trigger OnPreDataItem()
            begin
                if gdteWorkOrderDate = 0D then
                    Error(jfText002);

                Clear(gintCount);
                Clear(gintCounter);

                gdlgWindow.Open(jfText001);
                gintCount := Count;

                grecPMPlanWksht.SetRange("Worksheet Batch Name", gcodPMPlanWksht);
                if gblnClearWksht then begin
                    grecPMPlanWksht.DeleteAll;
                    gintNextLineNo := 10000;
                end else begin
                    if grecPMPlanWksht.Find('+') then
                        gintNextLineNo := grecPMPlanWksht."Line No." + 10000
                    else
                        gintNextLineNo := 10000;
                end;
                if gdteEndDate = 0D then
                    gdteEndDate := 99991231D;
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
                    field(gcodPMPlanWksht; gcodPMPlanWksht)
                    {
                        Caption = 'Batch Name';
                        TableRelation = "PM Worksheet Batch ELA".Name;
                    }
                    field(gblnClearWksht; gblnClearWksht)
                    {
                        Caption = 'Clear Worksheet';
                    }
                    field(gdteStartDate; gdteStartDate)
                    {
                        Caption = 'Start Date ';
                    }
                    field(gdteEndDate; gdteEndDate)
                    {
                        Caption = 'End Date ';
                    }
                    field(gdteWorkOrderDate; gdteWorkOrderDate)
                    {
                        Caption = 'New Work Order Date';
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
        grecPMPlanWksht: Record "PM Planning Worksheet ELA";
        grecPMSetup: Record "PM Procedure Header ELA";
        grecMachineCenter: Record "Machine Center";
        grecWorkCenter: Record "Work Center";
        grecFixedAsset: Record "Fixed Asset";
        grecPMCalcMethod: Record "PM Calc. Methods ELA";
        gcduPMMgt: Codeunit "PM Management ELA";
        gdteStartDate: Date;
        gdteEndDate: Date;
        gdteWorkOrderDate: Date;
        gdlgWindow: Dialog;
        jfText001: Label 'Creating Quality Audit @1@@@@@@@@@@@@@';
        gintCount: Integer;
        gintCounter: Integer;
        gcodPMPlanWksht: Code[10];
        gintNextLineNo: Integer;
        gdecCycles: Decimal;
        gdecTest: Decimal;
        gblnClearWksht: Boolean;
        gblnCreateWorkOrder: Boolean;
        jfText002: Label 'New Work Order Date must be filled in.';
        gblnExit: Boolean;

    [Scope('Internal')]
    procedure jfdoCalcQtyProduced()
    begin
        "PM Procedure Header".CalcFields("Last Work Order Date");
        "PM Procedure Header".SetRange("Date Filter", "PM Procedure Header"."Last Work Order Date", WorkDate);
        "PM Procedure Header".CalcFields("Qty. Produced", "Capacity Qty.");
        //<JF43819SHR>
        "PM Procedure Header".CalcFields("Stop Time");
        //</JF43819SHR>
    end;

    [Scope('Internal')]
    procedure jfdoCalcCycles()
    begin
        "PM Procedure Header".CalcFields(Cycles, "Cycles at Last Work Order");
    end;
}

