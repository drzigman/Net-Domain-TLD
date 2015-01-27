package Net::Domain::TLD;
use strict;
use base qw(Exporter);
use 5.006;
our @EXPORT_OK = qw(tlds tld_exists %tld_profile);
our $VERSION = '1.72';

use warnings;
use Carp;
use Storable qw ( dclone );

use constant TLD_TYPES => qw ( new_open new_restricted gtld_open gtld_restricted gtld_new cc ccidn );

=head1 NAME

  Net::Domain::TLD - Work with TLD names 

=head1 SYNOPSIS

  use Net::Domain::TLD qw(tlds tld_exists);
  my @ccTLDs = tlds('cc');
  print "TLD ok\n" if tld_exists('ac','cc');

=head1 DESCRIPTION

  The purpose of this module is to provide user with current list of 
  available top level domain names including new ICANN additions and ccTLDs
  Currently TLD definitions have been acquired from the following sources:

  http://www.icann.org/tlds/
  http://www.dnso.org/constituency/gtld/gtld.html
  http://www.iana.org/cctld/cctld-whois.htm
  https://www.iana.org/domains/root/db

=cut

our %tld_profile = (
  cc => {
    'ac' => q{Ascension Island},
    'ad' => q{Andorra},
    'ae' => q{United Arab Emirates},
    'af' => q{Afghanistan},
    'ag' => q{Antigua and Barbuda},
    'ai' => q{Anguilla},
    'al' => q{Albania},
    'am' => q{Armenia},
    'an' => q{Netherlands Antilles},
    'ao' => q{Angola},
    'aq' => q{Antartica},
    'ar' => q{Argentina},
    'as' => q{American Samoa},
    'at' => q{Austria},
    'au' => q{Australia},
    'aw' => q{Aruba},
    'ax' => q{Aland Islands},
    'az' => q{Azerbaijan},
    'ba' => q{Bosnia and Herzegovina},
    'bb' => q{Barbados},
    'bd' => q{Bangladesh},
    'be' => q{Belgium},
    'bf' => q{Burkina Faso},
    'bg' => q{Bulgaria},
    'bh' => q{Bahrain},
    'bi' => q{Burundi},
    'bj' => q{Benin},
    'bl' => q{Saint Barthelemy},
    'bm' => q{Bermuda},
    'bn' => q{Brunei Darussalam},
    'bo' => q{Bolivia},
    'bq' => q{Not assigned},
    'br' => q{Brazil},
    'bs' => q{Bahamas},
    'bt' => q{Bhutan},
    'bv' => q{Bouvet Island},
    'bw' => q{Botswana},
    'by' => q{Belarus},
    'bz' => q{Belize},
    'ca' => q{Canada},
    'cc' => q{Cocos (Keeling) Islands},
    'cd' => q{Congo, Democratic Republic of the},
    'cf' => q{Central African Republic},
    'cg' => q{Congo, Republic of},
    'ch' => q{Switzerland},
    'ci' => q{Cote d'Ivoire},
    'ck' => q{Cook Islands},
    'cl' => q{Chile},
    'cm' => q{Cameroon},
    'cn' => q{China},
    'co' => q{Colombia},
    'cr' => q{Costa Rica},
    'cu' => q{Cuba},
    'cv' => q{Cap Verde},
    'cw' => q{University of the Netherlands Antilles},
    'cx' => q{Christmas Island},
    'cy' => q{Cyprus},
    'cz' => q{Czech Republic},
    'de' => q{Germany},
    'dj' => q{Djibouti},
    'dk' => q{Denmark},
    'dm' => q{Dominica},
    'do' => q{Dominican Republic},
    'dz' => q{Algeria},
    'ec' => q{Ecuador},
    'ee' => q{Estonia},
    'eg' => q{Egypt},
    'eh' => q{Western Sahara},
    'er' => q{Eritrea},
    'es' => q{Spain},
    'et' => q{Ethiopia},
    'eu' => q{European Union},
    'fi' => q{Finland},
    'fj' => q{Fiji},
    'fk' => q{Falkland Islands (Malvina)},
    'fm' => q{Micronesia, Federal State of},
    'fo' => q{Faroe Islands},
    'fr' => q{France},
    'ga' => q{Gabon},
    'gb' => q{United Kingdom},
    'gd' => q{Grenada},
    'ge' => q{Georgia},
    'gf' => q{French Guiana},
    'gg' => q{Guernsey},
    'gh' => q{Ghana},
    'gi' => q{Gibraltar},
    'gl' => q{Greenland},
    'gm' => q{Gambia},
    'gn' => q{Guinea},
    'gp' => q{Guadeloupe},
    'gq' => q{Equatorial Guinea},
    'gr' => q{Greece},
    'gs' => q{South Georgia and the South Sandwich Islands},
    'gt' => q{Guatemala},
    'gu' => q{Guam},
    'gw' => q{Guinea-Bissau},
    'gy' => q{Guyana},
    'hk' => q{Hong Kong},
    'hm' => q{Heard and McDonald Islands},
    'hn' => q{Honduras},
    'hr' => q{Croatia/Hrvatska},
    'ht' => q{Haiti},
    'hu' => q{Hungary},
    'id' => q{Indonesia},
    'ie' => q{Ireland},
    'il' => q{Israel},
    'im' => q{Isle of Man},
    'in' => q{India},
    'io' => q{British Indian Ocean Territory},
    'iq' => q{Iraq},
    'ir' => q{Iran (Islamic Republic of)},
    'is' => q{Iceland},
    'it' => q{Italy},
    'je' => q{Jersey},
    'jm' => q{Jamaica},
    'jo' => q{Jordan},
    'jp' => q{Japan},
    'ke' => q{Kenya},
    'kg' => q{Kyrgyzstan},
    'kh' => q{Cambodia},
    'ki' => q{Kiribati},
    'km' => q{Comoros},
    'kn' => q{Saint Kitts and Nevis},
    'kp' => q{Korea, Democratic People's Republic},
    'kr' => q{Korea, Republic of},
    'kw' => q{Kuwait},
    'ky' => q{Cayman Islands},
    'kz' => q{Kazakhstan},
    'la' => q{Lao People's Democratic Republic},
    'lb' => q{Lebanon},
    'lc' => q{Saint Lucia},
    'li' => q{Liechtenstein},
    'lk' => q{Sri Lanka},
    'lr' => q{Liberia},
    'ls' => q{Lesotho},
    'lt' => q{Lithuania},
    'lu' => q{Luxembourg},
    'lv' => q{Latvia},
    'ly' => q{Libyan Arab Jamahiriya},
    'ma' => q{Morocco},
    'mc' => q{Monaco},
    'md' => q{Moldova, Republic of},
    'me' => q{Montenegro},
    'mf' => q{Saint Martin (French part)},
    'mg' => q{Madagascar},
    'mh' => q{Marshall Islands},
    'mk' => q{Macedonia, Former Yugoslav Republic},
    'ml' => q{Mali},
    'mm' => q{Myanmar},
    'mn' => q{Mongolia},
    'mo' => q{Macau},
    'mp' => q{Northern Mariana Islands},
    'mq' => q{Martinique},
    'mr' => q{Mauritania},
    'ms' => q{Montserrat},
    'mt' => q{Malta},
    'mu' => q{Mauritius},
    'mv' => q{Maldives},
    'mw' => q{Malawi},
    'mx' => q{Mexico},
    'my' => q{Malaysia},
    'mz' => q{Mozambique},
    'na' => q{Namibia},
    'nc' => q{New Caledonia},
    'ne' => q{Niger},
    'nf' => q{Norfolk Island},
    'ng' => q{Nigeria},
    'ni' => q{Nicaragua},
    'nl' => q{Netherlands},
    'no' => q{Norway},
    'np' => q{Nepal},
    'nr' => q{Nauru},
    'nu' => q{Niue},
    'nz' => q{New Zealand},
    'om' => q{Oman},
    'pa' => q{Panama},
    'pe' => q{Peru},
    'pf' => q{French Polynesia},
    'pg' => q{Papua New Guinea},
    'ph' => q{Philippines},
    'pk' => q{Pakistan},
    'pl' => q{Poland},
    'pm' => q{St. Pierre and Miquelon},
    'pn' => q{Pitcairn Island},
    'pr' => q{Puerto Rico},
    'ps' => q{Palestinian Territories},
    'pt' => q{Portugal},
    'pw' => q{Palau},
    'py' => q{Paraguay},
    'qa' => q{Qatar},
    're' => q{Reunion Island},
    'ro' => q{Romania},
    'rs' => q{Serbia},
    'ru' => q{Russian Federation},
    'rw' => q{Rwanda},
    'sa' => q{Saudi Arabia},
    'sb' => q{Solomon Islands},
    'sc' => q{Seychelles},
    'sd' => q{Sudan},
    'se' => q{Sweden},
    'sg' => q{Singapore},
    'sh' => q{St. Helena},
    'si' => q{Slovenia},
    'sj' => q{Svalbard and Jan Mayen Islands},
    'sk' => q{Slovak Republic},
    'sl' => q{Sierra Leone},
    'sm' => q{San Marino},
    'sn' => q{Senegal},
    'so' => q{Somalia},
    'sr' => q{Suriname},
    'ss' => q{Not assigned},
    'st' => q{Sao Tome and Principe},
    'su' => q{Soviet Union},
    'sv' => q{El Salvador},
    'sx' => q{SX Registry SA B.V.},
    'sy' => q{Syrian Arab Republic},
    'sz' => q{Swaziland},
    'tc' => q{Turks and Caicos Islands},
    'td' => q{Chad},
    'tf' => q{French Southern Territories},
    'tg' => q{Togo},
    'th' => q{Thailand},
    'tj' => q{Tajikistan},
    'tk' => q{Tokelau},
    'tl' => q{Timor-Leste},
    'tm' => q{Turkmenistan},
    'tn' => q{Tunisia},
    'to' => q{Tonga},
    'tp' => q{East Timor},
    'tr' => q{Turkey},
    'tt' => q{Trinidad and Tobago},
    'tv' => q{Tuvalu},
    'tw' => q{Taiwan},
    'tz' => q{Tanzania},
    'ua' => q{Ukraine},
    'ug' => q{Uganda},
    'uk' => q{United Kingdom},
    'um' => q{US Minor Outlying Islands},
    'us' => q{United States},
    'uy' => q{Uruguay},
    'uz' => q{Uzbekistan},
    'va' => q{Holy See (City Vatican State)},
    'vc' => q{Saint Vincent and the Grenadines},
    've' => q{Venezuela},
    'vg' => q{Virgin Islands (British)},
    'vi' => q{Virgin Islands (USA)},
    'vn' => q{Vietnam},
    'vu' => q{Vanuatu},
    'wf' => q{Wallis and Futuna Islands},
    'ws' => q{Western Samoa},
    'ye' => q{Yemen},
    'yt' => q{Mayotte},
    'yu' => q{Yugoslavia},
    'za' => q{South Africa},
    'zm' => q{Zambia},
    'zw' => q{Zimbabwe},
  },
  ccidn => {
    'xn--0zwm56d' => q{Internet Assigned Numbers Authority},
    'xn--11b5bs3a9aj6g' => q{Internet Assigned Numbers Authority},
    'xn--1qqw23a' => q{Guangzhou YU Wei Information Technology Co., Ltd.},
    'xn--3bst00m' => q{Eagle Horizon Limited},
    'xn--3ds443g' => q{TLD REGISTRY LIMITED},
    'xn--3e0b707e' => q{KISA (Korea Internet &amp; Security Agency)},
    'xn--45brj9c' => q{National Internet Exchange of India},
    'xn--45q11c' => q{Zodiac Scorpio Limited},
    'xn--4gbrim' => q{Suhub Electronic Establishment},
    'xn--54b7fta0cc' => q{Not assigned},
    'xn--55qw42g' => q{China Organizational Name Administration Center},
    'xn--55qx5d' => q{Computer Network Information Center of Chinese Academy of Sciences （China Internet Network Information Center）},
    'xn--6frz82g' => q{Afilias Limited},
    'xn--6qq986b3xl' => q{Tycoon Treasure Limited},
    'xn--80adxhks' => q{Foundation for Assistance for Internet Technologies and Infrastructure Development (FAITID)},
    'xn--80akhbyknj4f' => q{Internet Assigned Numbers Authority},
    'xn--80ao21a' => q{Association of IT Companies of Kazakhstan},
    'xn--80asehdb' => q{CORE Association},
    'xn--80aswg' => q{CORE Association},
    'xn--90a3ac' => q{Serbian National Register of Internet Domain Names (RNIDS)},
    'xn--90ais' => q{Not assigned},
    'xn--9t4b11yi5a' => q{Internet Assigned Numbers Authority},
    'xn--b4w605ferd' => q{Temasek Holdings (Private) Limited},
    'xn--c1avg' => q{Public Interest Registry},
    'xn--cg4bki' => q{SAMSUNG SDS CO., LTD},
    'xn--clchc0ea0b2g2a9gcd' => q{Singapore Network Information Centre (SGNIC) Pte Ltd},
    'xn--czr694b' => q{HU YI GLOBAL INFORMATION RESOURCES(HOLDING) COMPANY.HONGKONG LIMITED},
    'xn--czrs0t' => q{Wild Island, LLC},
    'xn--czru2d' => q{Zodiac Aquarius Limited},
    'xn--d1acj3b' => q{The Foundation for Network Initiatives “The Smart Internet”},
    'xn--d1alf' => q{Macedonian Academic Research Network Skopje},
    'xn--deba0ad' => q{Internet Assigned Numbers Authority},
    'xn--fiq228c5hs' => q{TLD REGISTRY LIMITED},
    'xn--fiq64b' => q{CITIC Group Corporation},
    'xn--fiqs8s' => q{China Internet Network Information Center},
    'xn--fiqz9s' => q{China Internet Network Information Center},
    'xn--flw351e' => q{Charleston Road Registry Inc.},
    'xn--fpcrj9c3d' => q{National Internet Exchange of India},
    'xn--fzc2c9e2c' => q{LK Domain Registry},
    'xn--g6w251d' => q{Internet Assigned Numbers Authority},
    'xn--gecrj9c' => q{National Internet Exchange of India},
    'xn--h2brj9c' => q{National Internet Exchange of India},
    'xn--hgbk6aj7f53bba' => q{Internet Assigned Numbers Authority},
    'xn--hlcj6aya9esc7a' => q{Internet Assigned Numbers Authority},
    'xn--hxt814e' => q{Zodiac Libra Limited},
    'xn--i1b6b1a6a2e' => q{Public Interest Registry},
    'xn--io0a7i' => q{Computer Network Information Center of Chinese Academy of Sciences （China Internet Network Information Center）},
    'xn--j1amh' => q{Ukrainian Network Information Centre (UANIC), Inc.},
    'xn--j6w193g' => q{Hong Kong Internet Registration Corporation Ltd.},
    'xn--jxalpdlp' => q{Internet Assigned Numbers Authority},
    'xn--kgbechtv' => q{Internet Assigned Numbers Authority},
    'xn--kprw13d' => q{Taiwan Network Information Center (TWNIC)},
    'xn--kpry57d' => q{Taiwan Network Information Center (TWNIC)},
    'xn--kput3i' => q{Beijing RITT-Net Technology Development Co., Ltd},
    'xn--l1acc' => q{Datacom Co.,Ltd},
    'xn--lgbbat1ad8j' => q{CERIST},
    'xn--mgb9awbf' => q{Telecommunications Regulatory Authority (TRA)},
    'xn--mgba3a4f16a' => q{Not assigned},
    'xn--mgbaam7a8h' => q{Telecommunications Regulatory Authority (TRA)},
    'xn--mgbab2bd' => q{CORE Association},
    'xn--mgbai9azgqp6j' => q{Not assigned},
    'xn--mgbayh7gpa' => q{National Information Technology Center (NITC)},
    'xn--mgbbh1a71e' => q{National Internet Exchange of India},
    'xn--mgbc0a9azcg' => q{Agence Nationale de Réglementation des Télécommunications (ANRT)},
    'xn--mgberp4a5d4ar' => q{Communications and Information Technology Commission},
    'xn--mgbpl2fh' => q{Not assigned},
    'xn--mgbtx2b' => q{Not assigned},
    'xn--mgbx4cd0ab' => q{MYNIC Berhad},
    'xn--ngbc5azd' => q{International Domain Registry Pty. Ltd.},
    'xn--node' => q{Not assigned},
    'xn--nqv7f' => q{Public Interest Registry},
    'xn--nqv7fs00ema' => q{Public Interest Registry},
    'xn--o3cw4h' => q{Thai Network Information Center Foundation},
    'xn--ogbpf8fl' => q{National Agency for Network Services (NANS)},
    'xn--p1acf' => q{Rusnames Limited},
    'xn--p1ai' => q{Coordination Center for TLD RU},
    'xn--pgbs0dh' => q{Agence Tunisienne d&#39;Internet},
    'xn--q9jyb4c' => q{Charleston Road Registry Inc.},
    'xn--qcka1pmc' => q{Charleston Road Registry Inc.},
    'xn--rhqv96g' => q{Stable Tone Limited},
    'xn--s9brj9c' => q{National Internet Exchange of India},
    'xn--ses554g' => q{KNET Co., LTd},
    'xn--unup4y' => q{Spring Fields, LLC},
    'xn--vermgensberater-ctb' => q{Deutsche Verm�gensberatung Aktiengesellschaft DVAG},
    'xn--vermgensberatung-pwb' => q{Deutsche Verm�gensberatung Aktiengesellschaft DVAG},
    'xn--vhquv' => q{Dash McCook, LLC},
    'xn--wgbh1c' => q{National Telecommunication Regulatory Authority - NTRA},
    'xn--wgbl6a' => q{Supreme Council for Communications and Information Technology (ictQATAR)},
    'xn--xhq521b' => q{Guangzhou YU Wei Information Technology Co., Ltd.},
    'xn--xkc2al3hye2a' => q{LK Domain Registry},
    'xn--xkc2dl3a5ee0h' => q{National Internet Exchange of India},
    'xn--y9a3aq' => q{Not assigned},
    'xn--yfro4i67o' => q{Singapore Network Information Centre (SGNIC) Pte Ltd},
    'xn--ygbi2ammx' => q{Ministry of Telecom &amp; Information Technology (MTIT)},
    'xn--zckzah' => q{Internet Assigned Numbers Authority},
    'xn--zfr164b' => q{China Organizational Name Administration Center},
  },
  gtld_new => {
    'abogado' => q{Top Level Domain Holdings Limited},
    'academy' => q{Half Oaks, LLC},
    'accountants' => q{Knob Town, LLC},
    'active' => q{The Active Network, Inc},
    'actor' => q{United TLD Holdco Ltd.},
    'adult' => q{ICM Registry AD LLC},
    'agency' => q{Steel Falls, LLC},
    'airforce' => q{United TLD Holdco Ltd.},
    'allfinanz' => q{Allfinanz Deutsche Verm�gensberatung Aktiengesellschaft},
    'alsace' => q{REGION D ALSACE},
    'amsterdam' => q{Gemeente Amsterdam},
    'android' => q{Charleston Road Registry Inc.},
    'aquarelle' => q{Aquarelle.com},
    'archi' => q{STARTING DOT LIMITED},
    'army' => q{United TLD Holdco Ltd.},
    'associates' => q{Baxter Hill, LLC},
    'attorney' => q{United TLD Holdco, Ltd},
    'auction' => q{United TLD HoldCo, Ltd.},
    'audio' => q{Uniregistry, Corp.},
    'autos' => q{DERAutos, LLC},
    'axa' => q{AXA SA},
    'band' => q{United TLD Holdco, Ltd},
    'bank' => q{fTLD Registry Services, LLC},
    'bar' => q{Punto 2012 Sociedad Anonima Promotora de Inversion de Capital Variable},
    'barclaycard' => q{Barclays Bank PLC},
    'barclays' => q{Barclays Bank PLC},
    'bargains' => q{Half Hallow, LLC},
    'bayern' => q{Bayern Connect GmbH},
    'beer' => q{Top Level Domain Holdings Limited},
    'berlin' => q{dotBERLIN GmbH &amp; Co. KG},
    'best' => q{BestTLD Pty Ltd},
    'bid' => q{dot Bid Limited},
    'bike' => q{Grand Hollow, LLC},
    'bio' => q{STARTING DOT LIMITED},
    'black' => q{Afilias Limited},
    'blackfriday' => q{Uniregistry, Corp.},
    'bloomberg' => q{Bloomberg IP Holdings LLC},
    'blue' => q{Afilias Limited},
    'bmw' => q{Bayerische Motoren Werke Aktiengesellschaft},
    'bnpparibas' => q{BNP Paribas},
    'boo' => q{Charleston Road Registry Inc.},
    'boutique' => q{Over Galley, LLC},
    'brussels' => q{DNS.be vzw},
    'budapest' => q{Top Level Domain Holdings Limited},
    'build' => q{Plan Bee LLC},
    'builders' => q{Atomic Madison, LLC},
    'business' => q{Spring Cross, LLC},
    'buzz' => q{DOTSTRATEGY CO.},
    'bzh' => q{Association www.bzh},
    'cab' => q{Half Sunset, LLC},
    'cal' => q{Charleston Road Registry Inc.},
    'camera' => q{Atomic Maple, LLC},
    'camp' => q{Delta Dynamite, LLC},
    'cancerresearch' => q{Australian Cancer Research Foundation},
    'capetown' => q{ZA Central Registry NPC trading as ZA Central Registry},
    'capital' => q{Delta Mill, LLC},
    'caravan' => q{Caravan International, Inc.},
    'cards' => q{Foggy Hollow, LLC},
    'care' => q{Goose Cross, LLC},
    'career' => q{dotCareer LLC},
    'careers' => q{Wild Corner, LLC},
    'cartier' => q{Richemont DNS Inc.},
    'casa' => q{Top Level Domain Holdings Limited},
    'cash' => q{Delta Lake, LLC},
    'catering' => q{New Falls. LLC},
    'center' => q{Tin Mill, LLC},
    'ceo' => q{CEOTLD Pty Ltd},
    'cern' => q{European Organization for Nuclear Research ("CERN")},
    'channel' => q{Charleston Road Registry Inc.},
    'cheap' => q{Sand Cover, LLC},
    'christmas' => q{Uniregistry, Corp.},
    'chrome' => q{Charleston Road Registry Inc.},
    'church' => q{Holly Fileds, LLC},
    'citic' => q{CITIC Group Corporation},
    'city' => q{Snow Sky, LLC},
    'claims' => q{Black Corner, LLC},
    'cleaning' => q{Fox Shadow, LLC},
    'click' => q{Uniregistry, Corp.},
    'clinic' => q{Goose Park, LLC},
    'clothing' => q{Steel Lake, LLC},
    'club' => q{.CLUB DOMAINS, LLC},
    'coach' => q{Koko Island, LLC},
    'codes' => q{Puff Willow, LLC},
    'coffee' => q{Trixy Cover, LLC},
    'college' => q{XYZ.COM LLC},
    'cologne' => q{NetCologne Gesellschaft für Telekommunikation mbH},
    'community' => q{Fox Orchard, LLC},
    'company' => q{Silver Avenue, LLC},
    'computer' => q{Pine Mill, LLC},
    'condos' => q{Pine House, LLC},
    'construction' => q{Fox Dynamite, LLC},
    'consulting' => q{United TLD Holdco, LTD.},
    'contractors' => q{Magic Woods, LLC},
    'cooking' => q{Top Level Domain Holdings Limited},
    'cool' => q{Koko Lake, LLC},
    'country' => q{Top Level Domain Holdings Limited},
    'credit' => q{Snow Shadow, LLC},
    'creditcard' => q{Binky Frostbite, LLC},
    'cricket' => q{dot Cricket Limited},
    'crs' => q{Federated Co-operatives Limited},
    'cruises' => q{Spring Way, LLC},
    'cuisinella' => q{SALM S.A.S.},
    'cymru' => q{Nominet UK},
    'dabur' => q{Dabur India Limited},
    'dad' => q{Charleston Road Registry Inc.},
    'dance' => q{United TLD Holdco Ltd.},
    'dating' => q{Pine Fest, LLC},
    'day' => q{Charleston Road Registry Inc.},
    'dclk' => q{Charleston Road Registry Inc.},
    'deals' => q{Sand Sunset, LLC},
    'degree' => q{United TLD Holdco, Ltd},
    'delivery' => q{Steel Station, LLC},
    'democrat' => q{United TLD Holdco Ltd.},
    'dental' => q{Tin Birch, LLC},
    'dentist' => q{United TLD Holdco, Ltd},
    'desi' => q{Desi Networks LLC},
    'design' => q{Top Level Design, LLC},
    'dev' => q{Charleston Road Registry Inc.},
    'diamonds' => q{John Edge, LLC},
    'diet' => q{Uniregistry, Corp.},
    'digital' => q{Dash Park, LLC},
    'direct' => q{Half Trail, LLC},
    'directory' => q{Extra Madison, LLC},
    'discount' => q{Holly Hill, LLC},
    'dnp' => q{Dai Nippon Printing Co., Ltd.},
    'docs' => q{Charleston Road Registry Inc.},
    'domains' => q{Sugar Cross, LLC},
    'doosan' => q{Doosan Corporation},
    'durban' => q{ZA Central Registry NPC trading as ZA Central Registry},
    'dvag' => q{Deutsche Verm�gensberatung Aktiengesellschaft DVAG},
    'eat' => q{Charleston Road Registry Inc.},
    'education' => q{Brice Way, LLC},
    'email' => q{Spring Madison, LLC},
    'emerck' => q{Merck KGaA},
    'energy' => q{Binky Birch, LLC},
    'engineer' => q{United TLD Holdco Ltd.},
    'engineering' => q{Romeo Canyon},
    'enterprises' => q{Snow Oaks, LLC},
    'equipment' => q{Corn Station, LLC},
    'esq' => q{Charleston Road Registry Inc.},
    'estate' => q{Trixy Park, LLC},
    'eurovision' => q{European Broadcasting Union (EBU)},
    'eus' => q{Puntueus Fundazioa},
    'events' => q{Pioneer Maple, LLC},
    'everbank' => q{EverBank},
    'exchange' => q{Spring Falls, LLC},
    'expert' => q{Magic Pass, LLC},
    'exposed' => q{Victor Beach, LLC},
    'fail' => q{Atomic Pipe, LLC},
    'farm' => q{Just Maple, LLC},
    'fashion' => q{Top Level Domain Holdings Limited},
    'feedback' => q{Top Level Spectrum, Inc.},
    'finance' => q{Cotton Cypress, LLC},
    'financial' => q{Just Cover, LLC},
    'firmdale' => q{Firmdale Holdings Limited},
    'fish' => q{Fox Woods, LLC},
    'fishing' => q{Top Level Domain Holdings Limited},
    'fit' => q{Minds + Machines Group Limited},
    'fitness' => q{Brice Orchard, LLC},
    'flights' => q{Fox Station, LLC},
    'florist' => q{Half Cypress, LLC},
    'flowers' => q{Uniregistry, Corp.},
    'flsmidth' => q{FLSmidth A/S},
    'fly' => q{Charleston Road Registry Inc.},
    'foo' => q{Charleston Road Registry Inc.},
    'forsale' => q{United TLD Holdco, LLC},
    'foundation' => q{John Dale, LLC},
    'frl' => q{FRLregistry B.V.},
    'frogans' => q{OP3FT},
    'fund' => q{John Castle, LLC},
    'furniture' => q{Lone Fields, LLC},
    'futbol' => q{United TLD Holdco, Ltd.},
    'gal' => q{Asociaci�n puntoGAL},
    'gallery' => q{Sugar House, LLC},
    'garden' => q{Top Level Domain Holdings Limited},
    'gbiz' => q{Charleston Road Registry Inc.},
    'gent' => q{COMBELL GROUP NV/SA},
    'ggee' => q{GMO Internet, Inc.},
    'gift' => q{Uniregistry, Corp.},
    'gifts' => q{Goose Sky, LLC},
    'gives' => q{United TLD Holdco Ltd.},
    'glass' => q{Black Cover, LLC},
    'gle' => q{Charleston Road Registry Inc.},
    'global' => q{Dot GLOBAL AS},
    'globo' => q{Globo Comunica��o e Participa��es S.A},
    'gmail' => q{Charleston Road Registry Inc.},
    'gmo' => q{GMO Internet, Inc.},
    'gmx' => q{1&1 Mail & Media GmbH},
    'goog' => q{Charleston Road Registry Inc.},
    'google' => q{Charleston Road Registry Inc.},
    'gop' => q{Republican State Leadership Committee, Inc.},
    'graphics' => q{Over Madison, LLC},
    'gratis' => q{Pioneer Tigers, LLC},
    'green' => q{Afilias Limited},
    'gripe' => q{Corn Sunset, LLC},
    'guide' => q{Snow Moon, LLC},
    'guitars' => q{Uniregistry, Corp.},
    'guru' => q{Pioneer Cypress, LLC},
    'hamburg' => q{Hamburg Top-Level-Domain GmbH},
    'hangout' => q{Charleston Road Registry Inc.},
    'haus' => q{United TLD Holdco, LTD.},
    'healthcare' => q{Silver Glen, LLC},
    'help' => q{Uniregistry, Corp.},
    'here' => q{Charleston Road Registry Inc.},
    'hermes' => q{Hermes International},
    'hiphop' => q{Uniregistry, Corp.},
    'hiv' => q{dotHIV gemeinnuetziger e.V.},
    'holdings' => q{John Madison, LLC},
    'holiday' => q{Goose Woods, LLC},
    'homes' => q{DERHomes, LLC},
    'horse' => q{Top Level Domain Holdings Limited},
    'host' => q{DotHost Inc.},
    'hosting' => q{Uniregistry, Corp.},
    'house' => q{Sugar Park, LLC},
    'how' => q{Charleston Road Registry Inc.},
    'ibm' => q{International Business Machines Corporation},
    'ifm' => q{ifm electronic gmbh},
    'immo' => q{Auburn Bloom, LLC},
    'immobilien' => q{United TLD Holdco Ltd.},
    'industries' => q{Outer House, LLC},
    'ing' => q{Charleston Road Registry Inc.},
    'ink' => q{Top Level Design, LLC},
    'institute' => q{Outer Maple, LLC},
    'insure' => q{Pioneer Willow, LLC},
    'international' => q{Wild Way, LLC},
    'investments' => q{Holly Glen, LLC},
    'irish' => q{Dot-Irish LLC},
    'iwc' => q{Richemont DNS Inc.},
    'jcb' => q{JCB Co., Ltd.},
    'jetzt' => q{New TLD Company AB},
    'joburg' => q{ZA Central Registry NPC trading as ZA Central Registry},
    'juegos' => q{Uniregistry, Corp.},
    'kaufen' => q{United TLD Holdco Ltd.},
    'kddi' => q{KDDI CORPORATION},
    'kim' => q{Afilias Limited},
    'kitchen' => q{Just Goodbye, LLC},
    'kiwi' => q{DOT KIWI LIMITED},
    'koeln' => q{NetCologne Gesellschaft für Telekommunikation mbH},
    'krd' => q{KRG Department of Information Technology},
    'kred' => q{KredTLD Pty Ltd},
    'lacaixa' => q{CAIXA D'ESTALVIS I PENSIONS DE BARCELONA},
    'land' => q{Pine Moon, LLC},
    'lat' => q{ECOM-LAC Federaci�n de Latinoam�rica y el Caribe para Internet y el Comercio Electr�nico},
    'latrobe' => q{La Trobe University},
    'lawyer' => q{United TLD Holdco, Ltd},
    'lds' => q{IRI Domain Management, LLC},
    'lease' => q{Victor Trail, LLC},
    'legal' => q{Blue Falls, LLC},
    'lgbt' => q{Afilias Limited},
    'lidl' => q{Schwarz Domains und Services GmbH & Co. KG},
    'life' => q{Trixy Oaks, LLC},
    'lighting' => q{John McCook, LLC},
    'limited' => q{Big Fest, LLC},
    'limo' => q{Hidden Frostbite, LLC},
    'link' => q{Uniregistry, Corp.},
    'loans' => q{June Woods, LLC},
    'london' => q{Dot London Domains Limited},
    'lotte' => q{Lotte Holdings Co., Ltd.},
    'lotto' => q{Afilias Limited},
    'ltda' => q{InterNetX Corp.},
    'luxe' => q{Top Level Domain Holdings Limited},
    'luxury' => q{Luxury Partners LLC},
    'madrid' => q{Comunidad de Madrid},
    'maison' => q{Victor Frostbite, LLC},
    'management' => q{John Goodbye, LLC},
    'mango' => q{PUNTO FA S.L.},
    'market' => q{Unitied TLD Holdco, Ltd},
    'marketing' => q{Fern Pass, LLC},
    'marriott' => q{Marriott Worldwide Corporation},
    'media' => q{Grand Glen, LLC},
    'meet' => q{Afilias Limited},
    'melbourne' => q{The Crown in right of the State of Victoria, represented by its Department of State Development, Business and Innovation},
    'meme' => q{Charleston Road Registry Inc.},
    'memorial' => q{Dog Beach, LLC},
    'menu' => q{Wedding TLD2, LLC},
    'miami' => q{Top Level Domain Holdings Limited},
    'mini' => q{Bayerische Motoren Werke Aktiengesellschaft},
    'moda' => q{United TLD Holdco Ltd.},
    'moe' => q{Interlink Co., Ltd.},
    'monash' => q{Monash University},
    'money' => q{Outer McCook, LLC},
    'mormon' => q{IRI Domain Management, LLC ("Applicant")},
    'mortgage' => q{United TLD Holdco, Ltd},
    'moscow' => q{Foundation for Assistance for Internet Technologies and Infrastructure Development (FAITID)},
    'motorcycles' => q{DERMotorcycles, LLC},
    'mov' => q{Charleston Road Registry Inc.},
    'nagoya' => q{GMO Registry, Inc.},
    'navy' => q{United TLD Holdco Ltd.},
    'network' => q{Trixy Manor, LLC},
    'neustar' => q{NeuStar, Inc.},
    'new' => q{Charleston Road Registry Inc.},
    'nexus' => q{Charleston Road Registry Inc.},
    'ngo' => q{Public Interest Registry},
    'nhk' => q{Japan Broadcasting Corporation (NHK)},
    'ninja' => q{United TLD Holdco Ltd.},
    'nra' => q{NRA Holdings Company, INC.},
    'nrw' => q{Minds + Machines GmbH},
    'nyc' => q{The City of New York by and through the New York City Department of Information Technology & Telecommunications},
    'okinawa' => q{BusinessRalliart inc.},
    'one' => q{One.com A/S},
    'ong' => q{Public Interest Registry},
    'onl' => q{I-REGISTRY Ltd., Niederlassung Deutschland},
    'ooo' => q{INFIBEAM INCORPORATION LIMITED},
    'organic' => q{Afilias Limited},
    'osaka' => q{Interlink Co., Ltd.},
    'otsuka' => q{Otsuka Holdings Co., Ltd.},
    'ovh' => q{OVH SAS},
    'paris' => q{City of Paris},
    'partners' => q{Magic Glen, LLC},
    'parts' => q{Sea Goodbye, LLC},
    'party' => q{Blue Sky Registry Limited},
    'pharmacy' => q{National Association of Boards of Pharmacy},
    'photo' => q{Uniregistry, Corp.},
    'photography' => q{Sugar Glen, LLC},
    'photos' => q{Sea Corner, LLC},
    'physio' => q{PhysBiz Pty Ltd},
    'pics' => q{Uniregistry, Corp.},
    'pictures' => q{Foggy Sky, LLC},
    'pink' => q{Afilias Limited},
    'pizza' => q{Foggy Moon, LLC},
    'place' => q{Snow Galley, LLC},
    'plumbing' => q{Spring Tigers, LLC},
    'pohl' => q{Deutsche Verm�gensberatung Aktiengesellschaft DVAG},
    'poker' => q{Afilias Domains No. 5 Limited},
    'porn' => q{ICM Registry PN LLC},
    'praxi' => q{Praxi S.p.A.},
    'press' => q{DotPress Inc.},
    'prod' => q{Charleston Road Registry Inc.},
    'productions' => q{Magic Birch, LLC},
    'prof' => q{Charleston Road Registry Inc.},
    'properties' => q{Big Pass, LLC},
    'property' => q{Uniregistry, Corp.},
    'pub' => q{United TLD Holdco Ltd.},
    'qpon' => q{dotCOOL, Inc.},
    'quebec' => q{PointQu�bec Inc},
    'realtor' => q{Real Estate Domains LLC},
    'recipes' => q{Grand Island, LLC},
    'red' => q{Afilias Limited},
    'rehab' => q{United TLD Holdco Ltd.},
    'reise' => q{dotreise GmbH},
    'reisen' => q{New Cypress, LLC},
    'reit' => q{National Association of Real Estate Investment Trusts, Inc.},
    'ren' => q{Beijing Qianxiang Wangjing Technology Development Co., Ltd.},
    'rentals' => q{Big Hollow,LLC},
    'repair' => q{Lone Sunset, LLC},
    'report' => q{Binky Glen, LLC},
    'republican' => q{United TLD Holdco Ltd.},
    'rest' => q{Punto 2012 Sociedad Anonima Promotora de Inversion de Capital Variable},
    'restaurant' => q{Snow Avenue, LLC},
    'reviews' => q{United TLD Holdco, Ltd.},
    'rich' => q{I-REGISTRY Ltd., Niederlassung Deutschland},
    'rio' => q{Empresa Municipal de Inform�tica SA - IPLANRIO},
    'rip' => q{United TLD Holdco Ltd.},
    'rocks' => q{United TLD Holdco, LTD.},
    'rodeo' => q{Top Level Domain Holdings Limited},
    'rsvp' => q{Charleston Road Registry Inc.},
    'ruhr' => q{regiodot GmbH &amp; Co. KG},
    'ryukyu' => q{BusinessRalliart inc.},
    'saarland' => q{dotSaarland GmbH},
    'sale' => q{United TLD Holdco, Ltd},
    'samsung' => q{SAMSUNG SDS CO., LTD},
    'sarl' => q{Delta Orchard, LLC},
    'sca' => q{SVENSKA CELLULOSA AKTIEBOLAGET SCA (publ)},
    'scb' => q{The Siam Commercial Bank Public Company Limited ("SCB")},
    'schmidt' => q{SALM S.A.S.},
    'schule' => q{Outer Moon, LLC},
    'schwarz' => q{Schwarz Domains und Services GmbH & Co. KG},
    'science' => q{dot Science Limited},
    'scot' => q{Dot Scot Registry Limited},
    'services' => q{Fox Castle, LLC},
    'sew' => q{SEW-EURODRIVE GmbH & Co KG},
    'sexy' => q{Uniregistry, Corp.},
    'shiksha' => q{Afilias Limited},
    'shoes' => q{Binky Galley, LLC},
    'shriram' => q{Shriram Capital Ltd.},
    'singles' => q{Fern Madison, LLC},
    'sky' => q{Sky IP International Ltd, a company incorporated in England and Wales, operating via its registered Swiss branch},
    'social' => q{United TLD Holdco Ltd.},
    'software' => q{United TLD Holdco, Ltd},
    'sohu' => q{Sohu.com Limited},
    'solar' => q{Ruby Town, LLC},
    'solutions' => q{Silver Cover, LLC},
    'soy' => q{Charleston Road Registry Inc.},
    'space' => q{DotSpace Inc.},
    'spiegel' => q{SPIEGEL-Verlag Rudolf Augstein GmbH & Co. KG},
    'supplies' => q{Atomic Fields, LLC},
    'supply' => q{Half Falls, LLC},
    'support' => q{Grand Orchard, LLC},
    'surf' => q{Top Level Domain Holdings Limited},
    'surgery' => q{Tin Avenue, LLC},
    'suzuki' => q{SUZUKI MOTOR CORPORATION},
    'sydney' => q{State of New South Wales, Department of Premier and Cabinet},
    'systems' => q{Dash Cypress, LLC},
    'taipei' => q{Taipei City Government},
    'tatar' => q{Limited Liability Company "Coordination Center of Regional Domain of Tatarstan Republic"},
    'tattoo' => q{Uniregistry, Corp.},
    'tax' => q{Storm Orchard, LLC},
    'technology' => q{Auburn Falls, LLC},
    'temasek' => q{Temasek Holdings (Private) Limited},
    'tienda' => q{Victor Manor, LLC},
    'tips' => q{Corn Willow, LLC},
    'tires' => q{Dog Edge, LLC},
    'tirol' => q{punkt Tirol GmbH},
    'today' => q{Pearl Woods, LLC},
    'tokyo' => q{GMO Registry, Inc.},
    'tools' => q{Pioneer North, LLC},
    'top' => q{Jiangsu Bangning Science & Technology Co.,Ltd.},
    'town' => q{Koko Moon, LLC},
    'toys' => q{Pioneer Orchard, LLC},
    'trade' => q{Elite Registry Limited},
    'training' => q{Wild Willow, LLC},
    'trust' => q{Artemis Internet Inc},
    'tui' => q{TUI AG},
    'university' => q{Little Station, LLC},
    'uno' => q{Dot Latin LLC},
    'uol' => q{UBN INTERNET LTDA.},
    'vacations' => q{Atomic Tigers, LLC},
    'vegas' => q{Dot Vegas, Inc.},
    'ventures' => q{Binky Lake, LLC},
    'versicherung' => q{dotversicherung-registry GmbH},
    'vet' => q{United TLD Holdco, Ltd},
    'viajes' => q{Black Madison, LLC},
    'video' => q{United TLD Holdco, Ltd},
    'villas' => q{New Sky, LLC},
    'vision' => q{Koko Station, LLC},
    'vlaanderen' => q{DNS.be vzw},
    'vodka' => q{Top Level Domain Holdings Limited},
    'vote' => q{Monolith Registry LLC},
    'voting' => q{Valuetainment Corp.},
    'voto' => q{Monolith Registry LLC},
    'voyage' => q{Ruby House, LLC},
    'wales' => q{Nominet UK},
    'wang' => q{Zodiac Leo Limited},
    'watch' => q{Sand Shadow, LLC},
    'webcam' => q{dot Webcam Limited},
    'website' => q{DotWebsite Inc.},
    'wed' => q{Atgron, Inc.},
    'wedding' => q{Top Level Domain Holdings Limited},
    'whoswho' => q{Who's Who Registry},
    'wien' => q{punkt.wien GmbH},
    'wiki' => q{Top Level Design, LLC},
    'williamhill' => q{William Hill Organization Limited},
    'wme' => q{William Morris Endeavor Entertainment, LLC},
    'work' => q{Top Level Domain Holdings Limited},
    'works' => q{Little Dynamite, LLC},
    'world' => q{Bitter Fields, LLC},
    'wtc' => q{World Trade Centers Association, Inc.},
    'wtf' => q{Hidden Way, LLC},
    'xyz' => q{XYZ.COM LLC},
    'yachts' => q{DERYachts, LLC},
    'yandex' => q{YANDEX, LLC},
    'yoga' => q{Top Level Domain Holdings Limited},
    'yokohama' => q{GMO Registry, Inc.},
    'youtube' => q{Charleston Road Registry Inc.},
    'zip' => q{Charleston Road Registry Inc.},
    'zone' => q{Outer Falls, LLC},
    'zuerich' => q{Kanton Z�rich (Canton of Zurich)},
  },
  gtld_open => {
    'com' => q{Commercial organization},
    'net' => q{Network connection services provider},
    'org' => q{Non-profit organizations and industry standard groups},
  },
  gtld_restricted => {
    'edu' => q{Educational institution},
    'gov' => q{United States Government},
    'int' => q{International treaties/databases},
    'mil' => q{United States Military},
  },
  new_open => {
    'info' => q{Unrestricted use},
    'xxx' => q{sponsored top-level domain},
  },
  new_restricted => {
    'aero' => q{Air-transport industry},
    'arpa' => q{Address and Routing Parameter Area},
    'asia' => q{Companies, organisations and individuals in the Asia-Pacific region},
    'biz' => q{Businesses},
    'cat' => q{Catalan linguistic and cultural community},
    'coop' => q{Cooperatives},
    'jobs' => q{Human Resource Management},
    'mobi' => q{Mobile},
    'museum' => q{Museums},
    'name' => q{For registration by individuals},
    'post' => q{Universal Postal Union},
    'pro' => q{Accountants, lawyers, and physicians},
    'tel' => q{For businesses and individuals to publish contact data},
    'travel' => q{Travel industry},
  },
  reserved => {
    'example' => q{Documentation names},
    'invalid' => q{Invalid names},
    'localhost' => q{Loopback names},
    'test' => q{DNS testing names},
  },
);
my $flat_profile = flatten ( \%tld_profile );

sub flatten {
  my $hashref = shift;
  my %results;
  @results{ keys %{ $hashref->{$_} } } = values % { $hashref->{$_} }
    for ( keys %$hashref );
  return \%results;
}

sub check_type {
  my $type = shift;
  croak "unknown TLD type: $type" unless grep { $type eq $_ } TLD_TYPES;
  return 1;
}

=head1 PUBLIC METHODS

  Each public function/method is described here.
  These are how you should interact with this module.

=head3 C<< tlds >>

  This routine returns the tlds requested.

  my @all_tlds = tlds; #array of tlds
  my $all_tlds = tlds; #hashref of tlds and their descriptions

  my @cc_tlds = tlds('cc'); #array of just 'cc' type tlds
  my $cc_tlds = tlds('cc'); #hashref of just 'cc' type tlds and their descriptions

  Valid types are:
    cc                 - country code domains
    ccidn              - internationalized country code top-level domain 
    gtld_open          - generic domains that anyone can register
    gtld_restricted    - generic restricted registration domains
    gtld_new           - new gTLDs
    new_open           - recently added generic domains
    new_restricted     - new restricted registration domains
    reserved           - RFC2606 restricted names, not returned by tlds

=cut

sub tlds {
  my $type = shift;
  check_type ( $type ) if $type;
  my $results = $type ? 
    wantarray ? [ keys %{ $tld_profile{$type} } ] : 
      dclone ( $tld_profile{$type} ) :
	wantarray ? [ map { keys %$_ } values %tld_profile ] : 
	  $flat_profile;
  return wantarray ? @$results : $results;
}

=head3 C<< tld_exists >>

  This routine returns true if the given domain exists and false otherwise.

  die "no such domain" unless tld_exists($tld); #call without tld type 
  die "no such domain" unless tld_exists($tld, 'new_open'); #call with tld type

=cut

sub tld_exists {
  my ( $tld, $type )  = ( lc ( $_[0] ), $_[1] );
  check_type ( $type ) if $type;
  my $result = $type ? 
    $tld_profile{$type}{$tld} ? 1 : 0 :
    $flat_profile->{$tld} ? 1 : 0;
  return $result;
}

=head1 COPYRIGHT

  Copyright (c) 2003-2014 Alex Pavlovic, all rights reserved.  This program
  is free software; you can redistribute it and/or modify it under the same terms
  as Perl itself.

=head1 AUTHORS

  Alexander Pavlovic <alex.pavlovic@taskforce-1.com>
  Ricardo SIGNES <rjbs@cpan.org>

=cut

1;
