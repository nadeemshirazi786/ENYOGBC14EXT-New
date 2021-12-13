page 14228884 "EN Price Authorization"
{

    PageType = Card;

    layout
    {
        area(content)
        {

            field(UsrID; UsrID)
            {
                Caption = 'User ID';
            }
            field(Password; Password)
            {
                ExtendedDatatype = Masked;
                ShowCaption = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OK)
            {
                Caption = 'OK';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if UsrID = '' then
                        Valid := false
                    else
                        if not User1.Get(UsrID) then
                            Valid := false
                        else begin

                            Error('Todo: Price Authorization password management - can''t use the User table for this in 2013 R2');

                            Message('!!! "User Setup"."Override Password" not implemented');

                        end;

                    if Valid then
                        CurrPage.Close
                    else
                        Error('The combination of user ID and password entered is invalid.  Try again.');

                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (
          (CloseAction <> ACTION::OK)
        ) then begin
            exit;
        end;

        if UsrID = '' then
            Valid := false
        else
            if not User1.Get(UsrID) then
                Valid := false
            else begin

                User1.TESTFIELD("Allow C&C Authorization ELA");

                Valid := User1."Approval Password ELA" = Password
            end;


        if not Valid then
            Error('The combination of user ID and password entered is invalid.  Try again.');
    end;

    var
        User1: Record "User Setup";
        User2: Record User;
        MsgText: Text[250];
        UsrID: Code[20];
        Password: Text[10];
        Valid: Boolean;


    procedure SetVariables(UnitPrice: Decimal; MinPrice: Decimal; Cost: Decimal)
    var
        PriceText: Text[30];
    begin

        if UnitPrice < MinPrice then
            PriceText := 'minimum sellng price'
        else begin
            PriceText := 'cost';
            MinPrice := Cost;
        end;

        MsgText := StrSubstNo('Unit price of %1 is below the %2 of %3.  ' +
          'Enter user ID and password to authorize this price.',
          Format(UnitPrice, 0, '<Precision,2:2><Standard Format,2>'),
          PriceText,
          Format(MinPrice, 0, '<Precision,2:2><Standard Format,2>'));
    end;


    procedure GetValidUser(): Code[20]
    begin
        if Valid then
            exit(UsrID)
        else
            exit('');
    end;
}

