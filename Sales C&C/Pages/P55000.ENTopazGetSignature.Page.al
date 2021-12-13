page 55000 "EN Topaz Get Signature"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = StandardDialog;
    SourceTable = "EN Sales Order Signature";

    layout
    {
        area(content)
        {
            /*usercontrol(TopazSigPlus; "IndustryBuilt.TopazSigPlusControlAddIn")
            {
            }TBR*/
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Clear Tablet")
                {
                    Image = Picture;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin

                        if (
                          (yogTabletConnectionTest(false))
                        ) then begin
                            yogClearTablet();
                        end;
                    end;
                }
            }
        }
    }

    trigger OnClosePage()
    begin
        yogCloseTablet();
    end;

    trigger OnOpenPage()
    var
        lcodSalesOrder: Code[20];
        ltxtFilters: Text;
        lctxtFiltersAreNotAllowed: Label 'Filters are not allowed when launching the Signature Capture page.\They have been reset.';
    begin
        lcodSalesOrder := GetRangeMin("Order No.");
        if (
          (lcodSalesOrder = '')
        ) then begin
            TestField("Order No.");
        end;
        SetRange("Order No.");
        ltxtFilters := GetFilters;
        if (
          (ltxtFilters <> '')
        ) then begin
            // Filters are not allowed when launching the Signature Capture page
            // They have been reset.
            Message(lctxtFiltersAreNotAllowed);
            Reset;
        end;
        FilterGroup(10);
        SetRange("Order No.", lcodSalesOrder);
        FilterGroup(0);
        if (
          (not FindFirst)
        ) then begin
            Init;
            "Order No." := lcodSalesOrder;
            Insert(true);
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        lctxt: Label 'No signature has been saved -- are you sure you want to exit?';
    begin
        if (
          (CloseAction = ACTION::OK)
        ) then begin
            if (
              (yogTabletConnectionTest(false))
            ) then begin
                yogGetSignature();
            end;
        end else begin
            if (
              (not Signature.HasValue)
            ) then begin
                exit(Confirm(lctxt, false));
            end;
        end;
    end;


    procedure yogTabletConnectionTest(pblnVerbose: Boolean): Boolean
    var
        lint: Integer;
        lbln: Boolean;
    begin
        //lbln := CurrPage.TopazSigPlus.IsTabletConnected(); TBR

        if (
          (lbln)
        ) then begin

            if (
              (pblnVerbose)
            ) then begin
                Message('Topaz Tablet is Connected.');
            end;

        end else begin

            Message('FAILURE - no Topaz Tablet detected.');

        end;

        exit(lbln);
    end;


    procedure yogStartSignatureCapture()
    begin

        if (
          (yogTabletConnectionTest(false))
        ) then begin

            // CurrPage.TopazSigPlus.StartSigCapture(); TBR

        end;
    end;


    procedure yogGetSignature()
    var
        //ldotnetMemoryStream: DotNet MemoryStream;TBR
        lostream: OutStream;
    begin
        if (
          (yogTabletConnectionTest(false))
        ) then begin

            // ldotnetMemoryStream := ldotnetMemoryStream.MemoryStream( CurrPage.TopazSigPlus.GetSigImageBinary() );TBR

            Signature.CreateOutStream(lostream);

            //ldotnetMemoryStream.WriteTo(lostream);TBR

            Modify(true);

        end;
    end;


    procedure yogClearTablet()
    begin
        if (
          (yogTabletConnectionTest(false))
        ) then begin
            //CurrPage.TopazSigPlus.ClearTablet(); TBR
        end;
    end;


    procedure yogCloseTablet()
    begin
        if (
          (yogTabletConnectionTest(false))
        ) then begin
            // CurrPage.TopazSigPlus.CloseTablet(); TBR
        end;
    end;
}

