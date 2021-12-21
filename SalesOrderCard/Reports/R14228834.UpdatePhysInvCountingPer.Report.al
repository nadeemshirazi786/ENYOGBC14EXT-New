report 14228834 "Update Phys Inv. Counting Per."
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF2297MG
    //   20090116 - new routine to update Next Counting Period for items/skus

    Caption = 'Update Phys. Inv. Counting Period';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Inventory Posting Group", "Gen. Prod. Posting Group", "Item Category Code", "Location Filter";

            trigger OnAfterGetRecord()
            var
                lintSKUCounter: BigInteger;
                lintSKUCount: BigInteger;
            begin
                gintCounter += 1;
                gdlgWindow.Update(1, Round(gintCounter / gintCount) * 10000);

                if Item."Phys Invt Counting Period Code" <> '' then begin
                    if Item."Last Counting Period Update" < gdteAsOfDate then begin
                        gcduPhysInvtCountMgt.SetHideValidationDialog(true);
                        gcduPhysInvtCountMgt.UpdateItemPhysInvtCount(Item);
                    end;
                end;

                if gblnUpdateSKUs then begin
                    gdlgWindow.Update(2, 0);

                    grecSKU.SetRange("Item No.", Item."No.");
                    Item.CopyFilter("Location Filter", grecSKU."Location Code");

                    if grecSKU.FindSet(true) then begin
                        lintSKUCounter := 0;
                        lintSKUCount := grecSKU.Count;

                        repeat
                            lintSKUCounter += 1;
                            gdlgWindow.Update(2, Round(lintSKUCounter / lintSKUCount) * 10000);

                            if grecSKU."Last Counting Period Update" < gdteAsOfDate then begin
                                gcduPhysInvtCountMgt.SetHideValidationDialog(true);
                                gcduPhysInvtCountMgt.UpdateSKUPhysInvtCount(grecSKU);
                            end;
                        until grecSKU.Next = 0;
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if gdteAsOfDate = 0D then
                    Error(gjfText003);

                if gblnUpdateSKUs then
                    gdlgWindow.Open(gjfText000 + gjfText001 + gjfText002)
                else
                    gdlgWindow.Open(gjfText000 + gjfText001);

                gintCount := Count;
                gintCounter := 0;
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
                    field(gdteAsOfDate; gdteAsOfDate)
                    {
                        Caption = 'As of Date';
                    }
                    field(gblnUpdateSKUs; gblnUpdateSKUs)
                    {
                        Caption = 'Update SKUs';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            gdteAsOfDate := WorkDate;
        end;
    }

    labels
    {
    }

    var
        gdteAsOfDate: Date;
        gblnUpdateSKUs: Boolean;
        gcduPhysInvtCountMgt: Codeunit "Phys. Invt. Count.-Management";
        grecSKU: Record "Stockkeeping Unit";
        gdlgWindow: Dialog;
        gintCounter: BigInteger;
        gintCount: BigInteger;
        gjfText000: Label 'Processing...\\';
        gjfText001: Label 'Item          @1@@@@@@@@@@';
        gjfText002: Label '\Stockkeeping Unit          @2@@@@@@@@@@';
        gjfText003: Label 'As of Date must not be blank';
}

