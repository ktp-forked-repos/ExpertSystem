% swilgt -g 'logtalk_load(expert_system)' -g 'start.'

%--OBJECT-SERIALIZER-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

:- object(serializer).
:- public([
        save/2,
        restore/1
]).

        save(Protocol, File):-
                protocol_property(Protocol, public(Predicates)),
                open(File, write, Stream),
                write_canonical(Stream, protocol(Protocol)), write(Stream, '.\n'),
                forall(conforms_to_protocol(Object, Protocol), save_object(Object, Predicates, Stream)),
                close(Stream).

        save_object(Object, Predicates, Stream):-
                object_data(Predicates, Object, [], Data),
                write_canonical(Stream, data(Data)),
                write(Stream, '.\n').

        object_data([], _, Data, Data).

        object_data([Functor/Arity| Predicates], Object, Data0, Data):-
                functor(Fact, Functor, Arity),
                findall(Fact, Object::Fact, Data1, Data0),
                object_data(Predicates, Object, Data1, Data).

        restore(File):-
                open(File, read, Stream),
                read_term(Stream, Term, []),
                restore_object(Term, _, Stream),
                close(Stream).

        restore_object(end_of_file, _, _).

        restore_object(protocol(Protocol), Protocol, Stream):-
                read_term(Stream, Term, []),
                restore_object(Term, Protocol, Stream).
        restore_object(data(Data), Protocol, Stream):-
                get_name(Data, X),
                create_object(X, [implements(Protocol)], [], Data),
                read_term(Stream, Term, []),
                restore_object(Term, Protocol, Stream).

        get_name([_,_,_,_,_,_,_,name(X)], X).

:- end_object.

%--PROTOCOL-CHARACTER----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

:- protocol(character).
:- public([name/1,
        gender/1,
        membership/1,
        age/1,
        weight/1,
        height/1,
        hair_length/1,
        hair_color/1
]).
:- end_protocol.

%--OBJECT-DATABASE-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

:- object(database).
:- public([is_name_in/1,
            get_head/2
]).
:- private(find/2).

        is_name_in(Name):-
                findall(Person, implements_protocol(Person,character), L),
                length(L, _),
                find(L, Name).

        find([H|T], Name):-
                ((H = Name)
                ;
                find(T, Name)).

        get_head([H|_], H).

:- end_object.

%--OBJECT-SCREEN---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

:- object(screen).
:- public(clear/0).

        clear:-
                shell(clear).

:- end_object.

%--START-PROGRAM---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

start:-
        screen::clear,
        serializer::restore('db.lgt'),
        menu::show_menu.

%--OBJECT-MENU-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

:- object(menu).
:- public(show_menu/0).
:- private([option/1,
            search/0,
            create/0,
            print_elements/1
]).

        show_menu:-
                nl, nl,
                write("***************************************"),nl,
                write("*                                     *"),nl,
                write("*         1. Wyszukaj osobe           *"),nl,
                write("*         2. Dodaj osobe              *"),nl,
                write("*         3. Koniec                   *"),nl,
                write("*                                     *"),nl,
                write("***************************************"),nl,nl,nl,
                write("Wybor: "), nl,
                read(Choose),
                option(Choose).

        option(1):-
                screen::clear,
                (not(search)
                ->
                (write("nie ma takiej osoby"), nl, nl)),
                ::show_menu.

        option(2):-
                screen::clear,
                create,
                ::show_menu.

        option(3):-
                screen::clear,
                write("Koniec"), nl, nl,
                serializer::save(character, 'db.lgt'),
                halt.

        create:-
                write("Nazwisko osoby: "), nl,
                read(Name_var),
                (database::is_name_in(Name_var)
                ->
                screen::clear,
                write("taka osoba juz istnieje!"),
                ::show_menu;
                true),
                screen::clear,

                write("Jakiej plci jest ta osoba?\n1. mezczyzna\n2. Kobieta\n"), nl,
                read(Gender),
                (Gender = 1 -> Gender_string = mezczyzna;
                Gender = 2 -> Gender_string = kobieta),
                screen::clear,

                write("Kim jest?\n1. Nauczycielem\n2. Podchorazym\n3. Pracownikiem batalionu\n4. Technikiem\n5. Studentem cywilnym\n"), nl,
                read(Membership),
                (Membership = 1 -> Membership_string = nauczyciel;
                Membership = 2 -> Membership_string = podchorazy;
                Membership = 3 -> Membership_string = pracownik_batalionu;
                Membership = 4 -> Membership_string = technik;
                Membership = 5 -> Membership_string = student_cywilny),
                screen::clear,

                write("W jakim jest wieku?\n1. Mlody\n2. W srednim wieku\n3. Stary"), nl,
                read(Age),
                (Age = 1 -> Age_string = mlody;
                Age = 2 -> Age_string = sredni;
                Age = 3 -> Age_string = stary),
                screen::clear,

                write("Jakiej jest wagi?\n1. Chudy\n2. Sredni\n3. Gruby\n4. Umiesniony"), nl,
                read(Weight),
                (Weight = 1 -> Weight_string = chudy;
                Weight = 2 -> Weight_string = sredni;
                Weight = 3 -> Weight_string = gruby;
                Weight = 4 -> Weight_string = umiesniony),
                screen::clear,

                write("Jakiego jest wzrostu?\n1. Niski\n2. Sredniego wzrostu\n3. Wysoki"), nl,
                read(Height),
                (Height = 1 -> Height_string = niski;
                Height = 2 -> Height_string = sredni;
                Height = 3 -> Height_string = wysoki),
                screen::clear,

                write("Jakiej dlugosci ma wlosy?\n1. brak\n2. krotkie\n3. Sredniej dlugosci\n4. Dlugie"), nl,
                read(Hair),
                (Hair = 1 -> Hair_string = brak;
                Hair = 2 -> Hair_string = krotkie;
                Hair = 3 -> Hair_string = srednie;
                Hair = 4 -> Hair_string = dlugie),
                screen::clear,

                write("Jakiego koloru wlosy?\n1. brak\n2. ciemne\n3. blond\n4. rude\n5. siwe"), nl,
                read(Hair_color),
                (Hair_color = 1 -> Hair_color_string = brak;
                Hair_color = 2 -> Hair_color_string = ciemne;
                Hair_color = 3 -> Hair_color_string = blond;
                Hair_color = 4 -> Hair_color_string = rude;
                Hair_color = 5 -> Hair_color_string = siwe),

                create_object(Name_var, [implements(character)], [], [name(Name_var), gender(Gender_string), membership(Membership_string), age(Age_string), weight(Weight_string), height(Height_string), hair_length(Hair_string), hair_color(Hair_color_string)]),

                screen::clear,
                write("Osoba dodana.").

        search:-
                write("Jakiej plci jest ta osoba?\n1. mezczyzna\n2. Kobieta\n"), nl,
                read(Gender),
                (Gender = 1 -> Gender_string = mezczyzna;
                Gender = 2 -> Gender_string = kobieta),
                findall(Person, (implements_protocol(Person, character), Person::gender(Gender_string)), L),
                length(L, Result),
                screen::clear,
                (Result = 0 -> screen::clear, write("Brak takiej osoby w bazie!"), ::show_menu;
                Result = 1 -> database::get_head(L, Head), screen::clear, write("Uwazam, ze to "), write(Head), ::show_menu; true),

                write("Kim jest?\n1. Nauczycielem\n2. Podchorazym\n3. Pracownikiem batalionu\n4. Technikiem\n5. Studentem cywilnym\n"), nl,
                read(Membership),
                (Membership = 1 -> Membership_string = nauczyciel;
                (Membership = 2) -> Membership_string = podchorazy;
                (Membership = 3) -> Membership_string = pracownik_batalionu;
                (Membership = 4) -> Membership_string = technik;
                (Membership = 5) -> Membership_string = student_cywilny),
                findall(Person1, (implements_protocol(Person1, character), Person1::gender(Gender_string), Person1::membership(Membership_string)), L1),
                length(L1, Result1),
                screen::clear,
                (Result1 = 0 -> screen::clear, write("Brak takiej osoby w bazie!"), ::show_menu;
                Result1 = 1 -> database::get_head(L1, Head1), screen::clear, write("Uwazam, ze to "), write(Head1), ::show_menu; true),

                write("W jakim jest wieku?\n1. Mlody\n2. W srednim wieku\n3. Stary"), nl,
                read(Age),
                (Age = 1 -> Age_string = mlody;
                Age = 2 -> Age_string = sredni;
                Age = 3 -> Age_string = stary),
                findall(Person2, (implements_protocol(Person2, character), Person2::gender(Gender_string), Person2::membership(Membership_string), Person2::age(Age_string)), L2),
                length(L2, Result2),
                screen::clear,
                (Result2 = 0 -> screen::clear, write("Brak takiej osoby w bazie!"), ::show_menu;
                Result2 = 1 -> database::get_head(L2, Head2), screen::clear, write("Uwazam, ze to "), write(Head2), ::show_menu; true),

                write("Jakiej jest wagi?\n1. Chudy\n2. Sredni\n3. Gruby\n4. Umiesniony"), nl,
                read(Weight),
                (Weight = 1 -> Weight_string = chudy;
                Weight = 2 -> Weight_string = sredni;
                Weight = 3 -> Weight_string = gruby;
                Weight = 4 -> Weight_string = umiesniony),
                findall(Person3, (implements_protocol(Person3, character), Person3::gender(Gender_string), Person3::membership(Membership_string), Person3::age(Age_string), Person3::weight(Weight_string)), L3),
                length(L3, Result3),
                screen::clear,
                (Result3 = 0 -> screen::clear, write("Brak takiej osoby w bazie!"), ::show_menu;
                Result3 = 1 -> database::get_head(L3, Head3), screen::clear, write("Uwazam, ze to "), write(Head3), ::show_menu; true),

                write("Jakiego jest wzrostu?\n1. Niski\n2. Sredniego wzrostu\n3. Wysoki"), nl,
                read(Height),
                (Height = 1 -> Height_string = niski;
                Height = 2 -> Height_string = sredni;
                Height = 3 -> Height_string = wysoki),
                findall(Person4, (implements_protocol(Person4, character), Person4::gender(Gender_string), Person4::membership(Membership_string), Person4::age(Age_string), Person4::weight(Weight_string), Person4::height(Height_string)), L4),
                length(L4, Result4),
                screen::clear,
                (Result4 = 0 -> screen::clear, write("Brak takiej osoby w bazie!"), ::show_menu;
                Result4 = 1 -> database::get_head(L4, Head4), screen::clear, write("Uwazam, ze to "), write(Head4), ::show_menu; true),

                write("Jakiej dlugosci ma wlosy?\n1. brak\n2. krotkie\n3. Sredniej dlugosci\n4. Dlugie"), nl,
                read(Hair),
                (Hair = 1 -> Hair_string = brak;
                Hair = 2 -> Hair_string = krotkie;
                Hair = 3 -> Hair_string = srednie;
                Hair = 4 -> Hair_string = dlugie),
                findall(Person5, (implements_protocol(Person5, character), Person5::gender(Gender_string), Person5::membership(Membership_string), Person5::age(Age_string), Person5::weight(Weight_string), Person5::height(Height_string), Person5::hair_length(Hair_string)), L5),
                length(L5, Result5),
                screen::clear,
                (Result5 = 0 -> screen::clear, write("Brak takiej osoby w bazie!"), ::show_menu;
                Result5 = 1 -> database::get_head(L5, Head5), screen::clear, write("Uwazam, ze to "), write(Head5), ::show_menu; true),

                write("Jakiego koloru wlosy?\n1. brak (nie ma wlosow)\n2. ciemne\n3. blond\n4. rude\n5. siwe"), nl,
                read(Hair_color),
                (Hair_color = 1 -> Hair_color_string = brak;
                Hair_color = 2 -> Hair_color_string = ciemne;
                Hair_color = 3 -> Hair_color_string = blond;
                Hair_color = 4 -> Hair_color_string = rude;
                Hair_color = 5 -> Hair_color_string = siwe),
                findall(Person6, (implements_protocol(Person6, character), Person6::gender(Gender_string), Person6::membership(Membership_string), Person6::age(Age_string), Person6::weight(Weight_string), Person6::height(Height_string), Person6::hair_length(Hair_string), Person6::hair_color(Hair_color_string)), L6),
                length(L6, Result6),
                screen::clear,
                (Result6 = 0 -> screen::clear, write("Brak takiej osoby w bazie!"), ::show_menu;
                Result6 = 1 -> database::get_head(L6, Head6), screen::clear, write("Uwazam, ze to "), write(Head6), ::show_menu; true),

                print_elements(L6),
                ::show_menu.

        print_elements([]):-
                screen::clear,
                write("nie ma takiej osoby!!"), nl, nl,
                ::show_menu.

        print_elements([Head|Tail]):-
                write("Czy to "), write(Head), write("?\n1.tak\n2.nie"), nl, nl,
                read(Odp),
                (Odp = 1,
                screen::clear,
                write("Zgadlem!"),
                ::show_menu
                ;
                screen::clear,
                print_elements(Tail)).

:- end_object.
