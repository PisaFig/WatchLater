import '../models/content_item.dart';

class MockData {
  static const String _tmdb = 'https://image.tmdb.org/t/p/w500';
  static const String _ytThumb = 'https://img.youtube.com/vi';

  static final List<ContentItem> movies = [
    ContentItem(
      id: 'movie_inception',
      title: 'Inception',
      description:
          'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.',
      posterUrl: '$_tmdb/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
      trailerYoutubeId: 'YoHD9XEInc0',
      contentType: 'movie',
      genres: ['Action', 'Sci-Fi', 'Thriller'],
      rating: 8.8,
      year: '2010',
      duration: '2h 28m',
    ),
    ContentItem(
      id: 'movie_interstellar',
      title: 'Interstellar',
      description:
          'A team of explorers travel through a wormhole in space in an attempt to ensure humanity\'s survival as Earth faces an agricultural collapse.',
      posterUrl: '$_tmdb/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      trailerYoutubeId: 'zSWdZVtXT7E',
      contentType: 'movie',
      genres: ['Adventure', 'Drama', 'Sci-Fi'],
      rating: 8.6,
      year: '2014',
      duration: '2h 49m',
    ),
    ContentItem(
      id: 'movie_dark_knight',
      title: 'The Dark Knight',
      description:
          'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.',
      posterUrl: '$_tmdb/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      trailerYoutubeId: 'EXeTwQWrcwY',
      contentType: 'movie',
      genres: ['Action', 'Crime', 'Drama'],
      rating: 9.0,
      year: '2008',
      duration: '2h 32m',
    ),
    ContentItem(
      id: 'movie_parasite',
      title: 'Parasite',
      description:
          'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the destitute Kim clan.',
      posterUrl: '$_tmdb/7IiTTgloROVTemplmzyl5vUS8Te.jpg',
      trailerYoutubeId: '5xH0HfJHsaY',
      contentType: 'movie',
      genres: ['Comedy', 'Drama', 'Thriller'],
      rating: 8.5,
      year: '2019',
      duration: '2h 12m',
    ),
    ContentItem(
      id: 'movie_dune',
      title: 'Dune',
      description:
          'Paul Atreides, a brilliant and gifted young man born into a great destiny beyond his understanding, must travel to the most dangerous planet in the universe to ensure the future of his family and his people.',
      posterUrl: '$_tmdb/d5NXSklXo0qyIYkgV48Zmu1Es3b.jpg',
      trailerYoutubeId: 'n9xhJrPXop4',
      contentType: 'movie',
      genres: ['Action', 'Adventure', 'Sci-Fi'],
      rating: 8.0,
      year: '2021',
      duration: '2h 35m',
    ),
  ];

  static final List<ContentItem> anime = [
    ContentItem(
      id: 'anime_aot',
      title: 'Attack on Titan',
      description:
          'After his hometown is destroyed and his mother is killed, young Eren Yeager vows to cleanse the earth of the giant humanoid Titans that have brought humanity to the brink of extinction.',
      posterUrl: '$_tmdb/hTP1DtLGFamjfu8WqjnuQdP1n4i.jpg',
      trailerYoutubeId: 'MGRm4IzK1SQ',
      contentType: 'anime',
      genres: ['Action', 'Drama', 'Fantasy'],
      rating: 9.1,
      year: '2013',
      duration: '24 min/ep',
    ),
    ContentItem(
      id: 'anime_demon_slayer',
      title: 'Demon Slayer',
      description:
          'A young boy becomes a demon slayer after his family is slaughtered and his younger sister is turned into a demon. He joins an organization of demon slayers to find a cure for his sister.',
      posterUrl: '$_tmdb/xUfRZu2mi8jH6SzQEJGP6tjBuYj.jpg',
      trailerYoutubeId: 'VQGCKyvzIM4',
      contentType: 'anime',
      genres: ['Action', 'Fantasy', 'Adventure'],
      rating: 8.7,
      year: '2019',
      duration: '23 min/ep',
    ),
    ContentItem(
      id: 'anime_opm',
      title: 'One Punch Man',
      description:
          'The story of Saitama, a hero who can defeat any opponent with a single punch but seeks to find a worthy opponent after growing bored of his overwhelming strength.',
      posterUrl: '$_tmdb/iE3s0lG5QVdEHOGZebmhLXFHtl1.jpg',
      trailerYoutubeId: '0sOD0lTbM4Q',
      contentType: 'anime',
      genres: ['Action', 'Comedy', 'Sci-Fi'],
      rating: 8.8,
      year: '2015',
      duration: '24 min/ep',
    ),
    ContentItem(
      id: 'anime_jjk',
      title: 'Jujutsu Kaisen',
      description:
          'A boy swallows a cursed talisman — the finger of a demon — and becomes cursed himself. He enters a shaman school to be able to locate the remaining fingers and avert disaster.',
      posterUrl: '$_tmdb/oMnUgbBiu5Z9Pmy0VPXrCz4u1nz.jpg',
      trailerYoutubeId: 'PKpGSykqzk4',
      contentType: 'anime',
      genres: ['Action', 'Horror', 'Supernatural'],
      rating: 8.6,
      year: '2020',
      duration: '23 min/ep',
    ),
    ContentItem(
      id: 'anime_fmab',
      title: 'Fullmetal Alchemist: Brotherhood',
      description:
          'Two brothers search for a Philosopher\'s Stone after an attempt to revive their deceased mother goes wrong, leaving them in damaged physical forms.',
      posterUrl: '$_tmdb/34m2tygAYBGqA9MXKhRDtzYd4Kd.jpg',
      trailerYoutubeId: '--IcmZkvL0Q',
      contentType: 'anime',
      genres: ['Action', 'Adventure', 'Drama'],
      rating: 9.1,
      year: '2009',
      duration: '24 min/ep',
    ),
  ];

  static final List<ContentItem> tvshows = [
    ContentItem(
      id: 'tv_breaking_bad',
      title: 'Breaking Bad',
      description:
          'A high school chemistry teacher turned methamphetamine manufacturer partners with a former student to secure his family\'s financial future as he battles terminal lung cancer.',
      posterUrl: '$_tmdb/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
      trailerYoutubeId: 'HhesaQXLuRY',
      contentType: 'tvshow',
      genres: ['Crime', 'Drama', 'Thriller'],
      rating: 9.5,
      year: '2008',
      duration: '5 Seasons',
    ),
    ContentItem(
      id: 'tv_stranger_things',
      title: 'Stranger Things',
      description:
          'When a young boy disappears, his mother, a police chief and his friends must confront terrifying supernatural forces in order to get him back.',
      posterUrl: '$_tmdb/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
      trailerYoutubeId: 'b9EkMc79ZSU',
      contentType: 'tvshow',
      genres: ['Drama', 'Fantasy', 'Horror'],
      rating: 8.7,
      year: '2016',
      duration: '4 Seasons',
    ),
    ContentItem(
      id: 'tv_the_bear',
      title: 'The Bear',
      description:
          'A young chef from the fine dining world returns to Chicago to run his family\'s sandwich shop after a tragedy, and tries to transform both the restaurant and himself.',
      posterUrl: '$_tmdb/sHFlbKS3WLqMnp9t2ghADIJFnuQ.jpg',
      trailerYoutubeId: 'a9-JSGX5LVA',
      contentType: 'tvshow',
      genres: ['Comedy', 'Drama'],
      rating: 8.6,
      year: '2022',
      duration: '3 Seasons',
    ),
    ContentItem(
      id: 'tv_got',
      title: 'Game of Thrones',
      description:
          'Nine noble families wage war against each other in order to gain control over the mythical land of Westeros. Meanwhile, a force threatens from the North.',
      posterUrl: '$_tmdb/u3bZgnGQ9T01sKnwLZv9EMkd7xp.jpg',
      trailerYoutubeId: 'bjqEWgDVPe0',
      contentType: 'tvshow',
      genres: ['Action', 'Adventure', 'Drama'],
      rating: 9.2,
      year: '2011',
      duration: '8 Seasons',
    ),
    ContentItem(
      id: 'tv_severance',
      title: 'Severance',
      description:
          'Mark leads a team of office workers whose memories have been surgically divided between their work and personal lives. When a mysterious colleague appears, he begins to question his work life and the people around him.',
      posterUrl: '$_tmdb/sJZnMBWCVWhbCuNXqOtMNkr9t5d.jpg',
      trailerYoutubeId: 'xEQP4VVuyrY',
      contentType: 'tvshow',
      genres: ['Drama', 'Mystery', 'Sci-Fi'],
      rating: 8.7,
      year: '2022',
      duration: '2 Seasons',
    ),
  ];

  static final List<ContentItem> sports = [
    ContentItem(
      id: 'sports_ufc300',
      title: 'UFC 300: Pereira vs. Hill',
      description:
          'Alex Pereira defends his light heavyweight title against Jamahal Hill in the main event of a historic UFC 300 card, delivering one of the most action-packed nights in UFC history.',
      posterUrl: '$_ytThumb/bOrQMMNbOAk/hqdefault.jpg',
      trailerYoutubeId: 'bOrQMMNbOAk',
      contentType: 'sports',
      genres: ['MMA', 'Combat Sports', 'UFC'],
      rating: 9.3,
      year: '2024',
      duration: '5h 30m',
    ),
    ContentItem(
      id: 'sports_ucl_final_2024',
      title: 'Champions League Final 2024',
      description:
          'Real Madrid claim their 15th European title with a stunning comeback against Borussia Dortmund at Wembley Stadium, with Vinicius Jr. scoring the decisive goal.',
      posterUrl: '$_ytThumb/wALiHYjBbYE/hqdefault.jpg',
      trailerYoutubeId: 'wALiHYjBbYE',
      contentType: 'sports',
      genres: ['Soccer', 'UEFA', 'Champions League'],
      rating: 9.0,
      year: '2024',
      duration: '2h 0m',
    ),
    ContentItem(
      id: 'sports_nba_finals_2024',
      title: 'NBA Finals 2024',
      description:
          'The Boston Celtics defeat the Dallas Mavericks 4-1 to claim their 18th NBA championship, cementing their legacy as one of the greatest dynasties in basketball history.',
      posterUrl: '$_ytThumb/pHzEJnGQiMA/hqdefault.jpg',
      trailerYoutubeId: 'pHzEJnGQiMA',
      contentType: 'sports',
      genres: ['Basketball', 'NBA', 'Playoffs'],
      rating: 8.7,
      year: '2024',
      duration: '2h 30m',
    ),
    ContentItem(
      id: 'sports_f1_monaco_2024',
      title: 'F1 Monaco Grand Prix 2024',
      description:
          'Charles Leclerc finally wins his home race in the most prestigious event on the Formula 1 calendar, ending his jinx at the Monaco Grand Prix in dominant fashion.',
      posterUrl: '$_ytThumb/4WJOKzx5GjM/hqdefault.jpg',
      trailerYoutubeId: '4WJOKzx5GjM',
      contentType: 'sports',
      genres: ['Formula 1', 'Motorsport', 'Racing'],
      rating: 8.9,
      year: '2024',
      duration: '2h 0m',
    ),
    ContentItem(
      id: 'sports_wimbledon_2024',
      title: 'Wimbledon 2024 Final',
      description:
          'Carlos Alcaraz defeats Novak Djokovic in a thrilling five-set final at Wimbledon, successfully defending his title and cementing his status as the best player on grass.',
      posterUrl: '$_ytThumb/h9VkEBFbXIY/hqdefault.jpg',
      trailerYoutubeId: 'h9VkEBFbXIY',
      contentType: 'sports',
      genres: ['Tennis', 'Grand Slam', 'Wimbledon'],
      rating: 9.1,
      year: '2024',
      duration: '4h 15m',
    ),
  ];

  static List<ContentItem> get all => [...movies, ...anime, ...tvshows, ...sports];

  static List<ContentItem> byType(String contentType) =>
      all.where((item) => item.contentType == contentType).toList();
}
