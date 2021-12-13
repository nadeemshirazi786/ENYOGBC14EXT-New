report 14229120 "EN Repack Order"
{

    DefaultLayout = RDLC;
    RDLCLayout = './RepackOrder.rdlc';

    Caption = 'Repack Order';
    UsageCategory = Documents;

    dataset
    {
        dataitem("Repack Order"; "EN Repack Order")
        {
            DataItemTableView = SORTING(Status);
            RequestFilterFields = "No.", "Item No.", "Date Required";
            column(RepackOrderNo; "No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = SORTING(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
                    column(RepackOrderItemNo; "Repack Order"."Item No.")
                    {
                    }
                    column(RepackOrderDesc; "Repack Order".Description)
                    {
                    }
                    column(RepackOrderRepackLocation; "Repack Order"."Repack Location")
                    {
                        IncludeCaption = true;
                    }
                    column(RepackOrderDestinationLocation; "Repack Order"."Destination Location")
                    {
                        IncludeCaption = true;
                    }
                    column(RepackOrderDateRequired; Format("Repack Order"."Date Required"))
                    {
                    }
                    column(RepackOrderUOMCode; "Repack Order"."Unit of Measure Code")
                    {
                    }
                    column(RepackOrderQuantity; "Repack Order".Quantity)
                    {
                        IncludeCaption = true;
                    }
                    column(LotTextOut; LotTextOut)
                    {
                    }
                    column(FarmText; FarmText)
                    {
                    }
                    column(BrandText; BrandText)
                    {
                    }
                    column(CopyText; CopyText)
                    {
                    }
                    column(CountryText; CountryText)
                    {
                    }
                    column(EmptyStringCaption; EmptyString)
                    {
                    }
                    column(OutputNo; OutputNo)
                    {
                    }
                    dataitem("Repack Order Line"; "EN Repack Order Line")
                    {
                        DataItemLink = "Order No." = FIELD("No.");
                        DataItemLinkReference = "Repack Order";
                        DataItemTableView = SORTING("Order No.", "Line No.");
                        column(RepackOrderLineType; Type)
                        {
                            IncludeCaption = true;
                        }
                        column(RepackOrderLineNo; "No.")
                        {
                            IncludeCaption = true;
                        }
                        column(RepackOrderLineDesc; Description)
                        {
                            IncludeCaption = true;
                        }
                        column(LocationText; LocationText)
                        {
                        }
                        column(RepackOrderLineUOMCode; "Unit of Measure Code")
                        {
                        }
                        column(RepackOrderLineQuantity; Quantity)
                        {
                            IncludeCaption = true;
                        }
                        column(LotTextIn; LotTextIn)
                        {
                        }
                        column(TransferText; TransferText)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            case Type of
                                Type::Item:
                                    begin
                                        if "Lot No." <> '' then
                                            LotTextIn := "Lot No."
                                        else
                                            LotTextIn := PadStr('', 30, '_');

                                        if "Source Location" <> '' then
                                            LocationText := "Source Location"
                                        else
                                            LocationText := PadStr('', 30, '_');

                                        TransferText := PadStr('', 30, '_');
                                    end;

                                Type::Resource:
                                    begin
                                        LotTextIn := '';
                                        LocationText := '';
                                        TransferText := '';
                                    end;
                            end;
                        end;
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    //CurrReport.PageNo := 1;TBR

                    if Number = 1 then
                        CopyText := ''
                    else begin
                        CopyText := Text001;
                        //mmas
                        /*if IsServiceTier then
                            OutputNo += 1;*///TBR
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, NoOfCopies + 1);

                    //mmas
                    /*if IsServiceTier then
                        OutputNo := 1;*///TBR
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if "Lot No." <> '' then
                    LotTextOut := "Lot No."
                else
                    LotTextOut := PadStr('', StrLen(LotTextOut), '_');

                if Farm <> '' then
                    FarmText := Farm
                else
                    FarmText := PadStr('', StrLen(FarmText), '_');

                if Brand <> '' then
                    BrandText := Brand
                else
                    BrandText := PadStr('', StrLen(BrandText), '_');


                if "Country/Region of Origin Code" = '' then
                    CountryText := PadStr('', StrLen(CountryText), '_')
                else begin
                    Country.Get("Country/Region of Origin Code");
                    CountryText := Country.Name;
                end;

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
                    field(NoOfCopies; NoOfCopies)
                    {
                        Caption = 'No. of Copies';
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
        RepackOrderCaption = 'Repack Order';
        OrderNoCaption = 'Order No.';
        ItemNoCaption = 'Item';
        DateRequiredCaption = 'Date Required';
        LocationCaption = 'Source Location';
        UOMCodeCaption = 'Unit of Measure';
        LotCaption = 'Lot No.';
        FarmCaption = 'Farm';
        BrandCaption = 'Brand';
        QuantityProducedCaption = 'Quantity Produced';
        PostingDateCaption = 'Posting Date';
        QuantityTransferredCaption = 'Quantity Transferred';
        QuantityConsumedCaption = 'Quantity Consumed';
        PAGENOCaption = 'Page';
        CountryCaption = 'Country of Origin';
    }

    var
        Country: Record "Country/Region";
        NoOfCopies: Integer;
        CopyText: Text[30];
        LotTextOut: Text[30];
        FarmText: Text[30];
        BrandText: Text[30];
        LotTextIn: Text[30];
        LocationText: Text[30];
        TransferText: Text[30];
        Text001: Label 'Copy';
        CountryText: Text[50];
        OutputNo: Integer;
        EmptyString: Label ' ';
}

