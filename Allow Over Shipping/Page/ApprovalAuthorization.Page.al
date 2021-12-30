page 50010 "Approval Authorization"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.

    Caption = 'Approval Authorization';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                label(Control2)
                {
                    // CaptionClass = FORMAT(STRSUBSTNO(Text000, gtxtDescription));
                    // MultiLine = true;
                    // ShowCaption=false;
                    // Style = Strong;
                    // StyleExpr = TRUE;tbr
                }
                field("User ID"; gcodUserID)
                {
                    Caption = 'User ID';
                    TableRelation = "User Setup"."User ID";
                }
                field(gtxtPassword; gtxtPassword)
                {
                    Caption = 'Password';
                    ExtendedDatatype = Masked;
                }
            }
        }
    }

    actions
    {
    }

    var
        Text000: Label 'You were not approved to %1.  Please get an authorized user to authenticate the change.';
        gcodUserID: Code[20];
        gtxtPassword: Text[100];
        Text001: Label 'User ID / Password combination was incorrect.';
        gtxtDescription: Text[250];

    [Scope('Internal')]
    procedure jfCheckPassword(): Boolean
    var
        lrecUserSetup: Record "User Setup";
    begin
        lrecUserSetup.GET(gcodUserID);
        IF (gtxtPassword = lrecUserSetup."Approval Password ELA") AND
           (gtxtPassword <> '')
        THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    [Scope('Internal')]
    procedure jfReturnUserID(): Code[20]
    begin
        IF jfCheckPassword THEN
            EXIT(gcodUserID)
        ELSE
            EXIT('');
    end;

    [Scope('Internal')]
    procedure jfSetDescription(ptxtDescription: Text[250])
    begin
        gtxtDescription := ptxtDescription;
    end;
}

