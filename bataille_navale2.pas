//BUT:le jeu de la bataille navale
//ENTREE:1 coordonnée
//SORTIE:touché coulé
program Bataille_Navale2;

uses crt,sysutils;

CONST
	NBBATEAU=5;
	MAXCASE=5;
	MINL=1;
	MAXL=50;
	MINC=1;
	MAXC=50;

Type
	positionBateau=(enLigne,enColonne,enDiag);
	etatBateau=(toucher,couler);
	etatFlotte=(aFlot,aSombrer);
	etatJoueur=(gagne,perd);

type
	cellule=record
		ligne:integer;
		col:integer;
	end;
	
	bateau=record
		nCase:array [1..MAXCASE] of cellule;
		taille:integer;
	end;
	
	flotte=record
		nBateau:array [1..NBBATEAU] of bateau;
	end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: créer une case
//ENTREE: une ligne et une colonne
//SORTIE: une cellule remplie
PROCEDURE CreateCase(l,c:integer; VAR nCell:cellule);
begin
	nCell.ligne:=l;
	nCell.col:=c;
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: créer les cases des bateau
//ENTREE: une cellule remplie et la taille des bateau
//SORTIE: un bateau remplie
FUNCTION createBateau(nCell:cellule; taille:integer):bateau;
var
	res:bateau;
	posBateau:positionBateau;
	i,p:integer;

begin
	
	p:=Random(3);
	posBateau:=positionBateau(p);
	res.taille:=taille;
	
	for i:=1 to MAXCASE do
	begin
		if (i<=taille) then
		begin
			res.nCase[i].ligne:=nCell.ligne;
			res.nCase[i].col:=nCell.col;
		end
		else
		begin
			res.nCase[i].ligne:=0;
			res.nCase[i].col:=0;
		end;
		
		if (posBateau=enLigne) then
			nCell.col:=nCell.col+1
		else
		if (posBateau=enColonne) then
			nCell.ligne:=nCell.ligne+1
		else
			if (posBateau=enDiag) then
		begin
			nCell.ligne:=nCell.ligne+1;
			nCell.col:=nCell.col+1;
		end;
	end;

	createBateau:=res;
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: créer les bateaux en fonction des joueurs
//ENTREE: les bateaux vides
//SORTIE: les bateaux remplis 
procedure fJoueur (var nBateau:bateau;var nCell:cellule); // créer la flotte de chaque player (valeur aleatoire ) appelée fonction createBateau
begin
	
	repeat
		nBateau.taille:=Random(MAXCASE)+3;
	until (nBateau.taille>2) and (nBateau.taille<=MAXCASE);
	
	repeat
		CreateCase((Random(MAXL)+MINL),(Random(MAXC)+MINL),nCell);
	until (nCell.ligne>=MINL) and (nCell.ligne<=MAXL-nBateau.taille) and (nCell.col>=MINC) and (nCell.col<=MAXC-nBateau.taille);

	nBateau:=createBateau(nCell,nBateau.taille);
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: initie la flotte des joueur
//ENTREE: les bateaux initialisés
//SORTIE: les flottes initialisées
procedure initfJoueur(var player:flotte; nCell:cellule); //initialisation des flotte ( appelée fJoueur)
var
  i:integer;
  //j:integer; //DEBUG<<<<<<<<<<<<<<<<<<<<<<<
begin
	for i:=1 to NBBATEAU do
	begin

		fJoueur(player.nBateau[i],nCell);
		
		// for j:=1 to MAXCASE do                                                             //DEBUG<<<<<<<<<<<<<<<<<<<<<<<
		// begin                                                                              //DEBUG<<<<<<<<<<<<<<<<<<<<<<<
		// 	write(' [',player.nBateau[i].nCase[j].ligne,player.nBateau[i].nCase[j].col,' ]'); //DEBUG<<<<<<<<<<<<<<<<<<<<<<<
		// end;                                                                               //DEBUG<<<<<<<<<<<<<<<<<<<<<<<
		// writeln;                                                                           //DEBUG<<<<<<<<<<<<<<<<<<<<<<<

	end;
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: édite les cases restantes de bateau
//ENTREE: le bateau
//SORTIE: le bateau et une variable ajustée
function tailleBateau(nBateau:bateau):integer;
var
	i,Acc:integer;
begin
	Acc:=0;

	for i:=1 to MAXCASE do
	begin
		if (nBateau.nCase[i].ligne<>0) or (nBateau.nCase[i].col<>0) then
			Acc:=Acc+1;
	end;

	tailleBateau:=Acc;
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: voir l'etat toucher ou couler du bateau
//ENTREE: l'etat
//SORTIE: la réponse de l'etat
function etatBateau(nBateau:bateau):etatBateau;
var
	etat:integer;
begin
	etat:=tailleBateau(nBateau);
	if (etat<nBateau.taille) and (etat>0) then 
		etatBateau:=toucher
	else if (etat=0) then 
		etatBateau:=couler;
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: voir l'etat aflot ou asombrer de la flotte entière
//ENTREE: la flotte entière
//SORTIE: la réponse si la flotte complète à coulé ou non
function etatFlot(player:flotte):etatFlotte;
var
	i,Acc:integer;
begin
	Acc:=0;
	
	for i:=1 to NBBATEAU do
	begin
		if (etatBateau(player.nBateau[i])=couler) then	
			Acc:=Acc+1;

		delay(10);//J'ai dût travailler avec gokhan pour que nous puissions comprendre qu'il fallait un delay ou un write
				  //pour que l'ordi arrive à tout traiter normalement (en tout cas je pense)
	end;
	
	if Acc=NBBATEAU then etatFlot:=aSombrer
	else 
		etatFlot:=aFlot;
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT:Comparer deux cases
//ENTREE:deux cases
//SORTIE:un booleen qui donne si les cases sont identiques
FUNCTION cmpCase(nCell,tCellule:cellule):boolean;
begin
	if ((nCell.col=tCellule.col) and (nCell.ligne=tCellule.ligne)) then
		cmpCase:=true
	else
		cmpCase:=false;
end;

//--------------------------------------------------------------------------------------------------------------------	
//BUT: tour d'attaque des joueurs
//ENTREE: la flotte du joueur adverse
//SORTIE: la réponse si touché ou couler ou rien
procedure atkBat(var player:flotte);
var
	nCell:cellule;
	test:boolean;
	i,j:integer;
begin
	
	writeln('Entrez la ligne [1-50]');
	readln(nCell.ligne);
	
	writeln('Entrez la colonne [1-50]');
	readln(nCell.col);
	
	for i:=1 to NBBATEAU do //recherche par bateau
	begin
		for j:=1 to player.nBateau[i].taille do // boucle de recherche de partie de bateau
		begin
			test:=false;
			
			test:=cmpCase(nCell,player.nBateau[i].nCase[j]);
		
			if test then
			begin
				writeln('touche !');
				CreateCase(0,0,player.nBateau[i].nCase[j]); //si on le touche on lui met 0,0 pour qu'il ne soit plus dans taille
				if etatBateau(player.nBateau[i])=couler then 
					writeln('couler !');
			end;
		end;
	end;
end;
//--------------------------------------------------------------------------------------------------------------------
//-----------------------------------------------DEBUT DU PROGRAMME---------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------

var
	nCell:cellule;
	l,c,i:integer;
	tabBateau:bateau;
	J1,J2:flotte;
	etatJ1,etatJ2:etatJoueur;
	etatfl1,etatfl2:etatFlotte;

begin
	clrscr;
//--------------------------------------------------initialisation----------------------------------------------------

	randomize;
	etatJ1:=gagne;
	etatJ2:=gagne;
	etatfl1:=aFlot;
	etatfl2:=aFlot;
	
	initfJoueur(J1,nCell);
	initfJoueur(J2,nCell);

//------------------------------------------------fin initialisation--------------------------------------------------
	repeat//boucle de jeu
		
		if (etatJ1=gagne) and (etatJ2=gagne) then
			atkBat(J1);
		
		etatfl1:=etatFlot(J1);
		
		if etatfl1=aSombrer then 
			etatJ2:=perd;
		
		if (etatJ1=gagne) and (etatJ2=gagne) then
			atkBat(J2);
		
		etatfl2:=etatFlot(J2);
		
		if etatfl2=aSombrer then 
			etatJ1:=perd;
	
	until ((etatJ1=perd) or (etatJ2=perd));
	
	if etatJ1= perd then 
	begin
		writeln('Joueur 2 a gagner');
		writeln('Joueur 1 a perdu');
	end
	else
	begin
		writeln('Joueur 1 a gagner');
		writeln('Joueur 2 a perdu')
	end;
	
	readln;
end.

//--------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------FIN DU PROGRAMME---------------------------------------------------
//--------------------------------------------------------------------------------------------------------------------