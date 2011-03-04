# encoding: UTF-8

require 'iconv'
require 'yaml'

convs = {
  "Virginia wyglądała na jedną z tych dziewcząt, które bez spiralki antykoncepcyjnej czują się jak bez pantofli" => "british-museum-w-posadach-drzy",
  "Jak do tej czarnej skóry doszedł jeszcze homoseksualizm, to wielkiej różnicy w mojej sytuacji nie odczułem" => "homoseksualizm-do-czarnej-skory",
  "ale, teraz się rozbrajająco uśmiecham, i się zastanawiam – w co wierzysz, bo [żart] mi wszystko przysłonił" => "zart-mi-wszystko-przyslonil",
  "Words flowing out just like the Grand Canyon (and I’m always out looking for a female companion)" => "words-flowing-out",
  "(Pewno już wszyscy czytali, i tylko ja taki zapóźniony jestem, ale może nie, to proszę bardzo.)" => "pewno-juz-wszyscy-czytali",
  "Termin „mat” pochodzi od arabskiego zwrotu ash-shaykh mat, który znaczy „szejk został zabity”" => "szejk-zostal-zabity",
  "Alboż to się opłaci marnować czas na zastanawianiu się, czem jest kurz i na co się przyda?" => "czem-jest-kurz",
  "Nie ma nic milszego, niech kto chce mi wierzy, niż rodzinny obiad w sielskiej atmosferze" => "obiad-rodzinny",
  "Kto mi powie, kto odgadnie w głębi ocznych zwierciadełek, co u dziewcząt siedzi na dnie…" => "kto-mi-powie-kto-odgadnie",
  "Ja preferuję relaks w rytmie roots-reggae-ragga (to w dobie chaosu idealna przeciwwaga)" => "roots-reggae-ragga",
  "I saw the best minds of my generation destroyed by madness, starving hysterical naked" => "i-saw-the-best-minds-of-my-generation",
  "Drugi koniec semestru prędkości nabiera (niejeden się pogubi bez pomocy przyjaciela)" => "drugi-koniec-semestru",
  "Zero i dwie dwójki – to mój kierunkowy (fristajl – takie teksty zapodawać „z głowy”)" => "zero-i-dwie-dwojki-to-moj-kierunkowy",
  "Smoother words, nicer suits – don’t be fooled, they’re still wearing jackboots" => "smoother-words-nicer-suits",
  "Z tłumem szalał, piątkowy kod cud ten wyprawił – i wszyscy śpiewali go tak:" => "z-tlumem-szalal",
  "Przed snem nie należy też sprawdzać, czy Wesnoth 1.1.7 aby dobrze działa" => "przed-snem-nie-nalezy",
  "10.3.11. Some Special Cases Where the Collation Determination Is Tricky" => "some-special-cases",
  "This is my rifle, this is my GNU. This is for killing, this is for $foo." => "this-is-my-rifle-this-is-my-gnu",
  "The footsteps of a teleporting unit show haloes on teleport points" => "the-footsteps-of-a-teleporting-unit",
  "(Więc daj mi, daj mi, daj mi, daj mi, daj mi boga policji i boga armii)" => "wiec-daj-mi",
  "Pernter, Pfaundler, Schreiber, Süring i Trabert (przeważnie Austriacy)" => "przewaznie-austriacy",
  "Siedzimy we trójkę z Welshem i Powellem i kolorujemy sobie grafy" => "siedzimy-we-trojke",
  "Necromancer can now be female when advanced from Dark Sorceress" => "necromancer-can-now-be-female",
  "Znów dziś myślałem o emigracji (to jest melodia mojej generacji)" => "znow-dzis-myslalem-o-emigracji",
  "chciałbym mieć Cię całą dla siebie i nigdzie się nie spieszyć" => "chcialbym-miec-cie-cala",
  "Chaos zawsze pokonuje porządek, gdyż jest lepiej zorganizowany" => "chaos-zawsze-pokonuje-porzadek",
  "A communication disruption can mean only one thing… Invasion." => "a-communication-disruption",
  "Bóg nie gra w kości prehistorycznych gadów; górale oburzeni" => "bog-nie-gra-w-kosci",
  "The maze was so small that people got lost looking for it" => "the-maze-was-so-small",
  "Zważono 61 chomików – ich masy ciała były nieco prawoskośne" => "zwazono-61-chomikow",
  "Jak zachować trzeźwy dystans do rzeczywistości – samouczek" => "trzezwy-dystans-do-rzeczywistosci",
  "(Chcę Ci powiedzieć „uważaj na te drogi” ale nie mam odwagi)" => "uwazaj-na-te-drogi",
  "I see the girls walk by dressed in their summer clothes" => "i-see-the-girls-walk-by",
  "Nerdish, czyli niedziele w Tarabuku czystą przyjemnością" => "nerdish",
  "A to Polska właśnie, odcinek kolejny: „Wydział Komunikacji”" => "wydzial-komunikacji",
  "Panowie, odkryłem straszną prawdę – jesteśmy w środku węża" => "panowie-odkrylem-straszna-prawde",
  "(Co zrobi Paweł Janas gdy jego drużyna wygra mistrzostwa?)" => "co-zrobi-pawel-janas",
  "Said the Duck to the Kangaroo, ‘Good gracious! How you hop!’" => "said-the-duck-to-the-kangaroo",
  "…but do not trust to hope – it has forsaken these lands" => "but-do-not-trust-to-hope",
  "A kiedyś przez chwilę widziałem nawet Ostrego i Asha" => "a-kiedys-przez-chwile",
  "Komedia romantyczna, musical akcji i horror w jednym" => "tobiasz",
  "Mondays are an awful way to spend 1/7th of your life" => "mondays",
  "Aż dziw bierze, że nie wzorują się na zagranicznych" => "az-dziw-bierze",
  "Piszący wykonywa ruchy, odstępy uskutecznia motor" => "piszacy-wykonywa-ruchy",
  "„Maceachran”… tego się nie da poprawnie przeczytać" => "maceachran",
  "Łódź moim miastem, gdzie mnie nie zdziwi nic już" => "lodz-moim-miastem",
  "Mam wszystko czego może chcieć uczciwy człowiek" => "mam-wszystko",
  "Kim jest ten człowiek, który ciągle za mną idzie?" => "kim-jest-ten-czlowiek",
  "En1aRge Y0uR THeS1s! M4ke y0ur ADv1sor Happ1er!" => "en1arge-y0ur-thes1s",
  "…and the people passin’ by stare in wild wonder" => "and-the-people-passin-by",
  "When the going gets tough, the tough use print()" => "when-the-going-gets-tough",
  "„Torsje koneksji”, dramat produkcji węgierskiej" => "torsje-koneksji",
  "It takes a man to suffer ignorance – and smile…" => "it-takes-a-man",
  "What we need is a break from the old routine" => "what-we-need-is-a-break",
  "Kto chce być dobrym inżynierem informatyki?" => "kto-chce-byc-dobrym",
  "Najlepsze naleśniki są na placu Zbawiciela" => "najlepsze-nalesniki",
  "There never was a city kid truer and bluer" => "there-never-was-a-city-kid",
  "I może bardzo wielu nie zrozumie tych słów…" => "nie-ma-litosci",
  "A mówią, że to ja jestem zbyt zorganizowany" => "a-mowia-ze-to-ja",
  "Drunk on illusions of grandeur and godhood" => "drunk-on-illusions",
  "(Dlatego wznieśmy ręce, podajmy sobie dłonie.)" => "dlatego-wzniesmy-rece",
  "Wullfamorgenthalera trzeba będzie dopisać" => "dailystrips",
  "Divadélko „Zelená husa“ má tu čest předvést…" => "divadelko-zelena-husa",
  "Stürmisch ziehen Wolken bis zum Horizont" => "sturmisch-ziehen-wolken",
  "Oh, darling, I guess my mind’s more at ease" => "oh-darling",
  "Zaczęła też wygrywać ze mną w piłkarzyki" => "zaczela-tez-wygrywac",
  "A ja stoję dzieciak teraz z otwartą gębą…" => "a-ja-stoje-dzieciak-teraz",
  "Muszę się do Malko po tę książkę zgłosić" => "bodzianowski",
  "Tunnel vision from the outsider’s screen(1)" => "tunnel-vision",
  "Gigantyczne ślimaki zajmą miejsce ludzi" => "gigantyczne-slimaki",
  "And this is supposed to be a good thing" => "and-this-is-supposed",
  "Opisy niedobre… bardzo niedobre opisy są" => "opisy-niedobre",

  "[…]" => "promocja-startupa",
  "…²" => "koszulka-sie-nalezy",
  "Сестра" => "sestra",
  "Сквозь грозы сияло нам солнце свободы" => "skvoz-grozy-sialo-nam-solnce-svobody",

  "Spyware – the good, the bad and the tasty" => "spyware",
  "prenumerata@axelspringer.com.pl" => "prenumerata-axelspringer.com.pl",
  "Samolo^W fotolog" => "fotolog",
  "Me try φ get by" => "me-try-fi-get-by",
  "5.times { puts 'No, boski, po prostu.' }" => "5-times-puts",
}

ARGV.each do |file|
  yaml, _ = File.read(file).split "\n\n", 2
  title = YAML.load(yaml)['title']
  orig = title.dup
  title = Iconv.new('ASCII//TRANSLIT//IGNORE', 'UTF-8').iconv title
  title.downcase!
  title.tr! ' _', '--'
  title.tr! '^a-z0-9-', ''
  title.gsub! /-+/, '-'
  convs[orig] ||= title
# puts "#{file}\t#{convs[orig]}\t\t\t\t\t\t\t#{orig}"
  system "git mv #{file} #{convs[orig]}.pl.md"
end
