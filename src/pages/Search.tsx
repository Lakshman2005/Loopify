import { useState } from "react";
import { SearchBar } from "@/components/SearchBar";
import { TrackCard } from "@/components/TrackCard";
import { AlbumCard } from "@/components/AlbumCard";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Music, User, Disc3 } from "lucide-react";

// Mock search results
const searchResults = {
  tracks: [
    {
      id: "1",
      title: "Starlight",
      artist: "Luna Echo",
      album: "Midnight Vibes",
      duration: 243,
      cover: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop&crop=faces"
    },
    {
      id: "2",
      title: "Neon Nights",
      artist: "Neon Pulse",
      album: "Electric Dreams",
      duration: 198,
      cover: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=400&fit=crop&crop=faces"
    },
  ],
  albums: [
    {
      id: "1",
      title: "Midnight Vibes",
      artist: "Luna Echo",
      cover: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop&crop=faces",
      year: 2024,
      trackCount: 12
    },
  ],
  artists: [
    {
      id: "1",
      name: "Luna Echo",
      image: "https://images.unsplash.com/photo-1494790108755-2616c02c8a5d?w=400&h=400&fit=crop&crop=faces",
      followers: "1.2M"
    },
  ]
};

const recentSearches = [
  "Luna Echo",
  "Chill music",
  "Electronic",
  "Indie rock"
];

const topGenres = [
  { name: "Pop", color: "bg-gradient-to-br from-pink-500 to-purple-600" },
  { name: "Rock", color: "bg-gradient-to-br from-red-500 to-orange-600" },
  { name: "Hip Hop", color: "bg-gradient-to-br from-green-500 to-teal-600" },
  { name: "Electronic", color: "bg-gradient-to-br from-blue-500 to-cyan-600" },
  { name: "Jazz", color: "bg-gradient-to-br from-yellow-500 to-orange-600" },
  { name: "Classical", color: "bg-gradient-to-br from-purple-500 to-indigo-600" },
];

interface SearchProps {
  onPlayTrack: (track: any) => void;
  currentTrack?: any;
  isPlaying: boolean;
}

export default function Search({ onPlayTrack, currentTrack, isPlaying }: SearchProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [hasSearched, setHasSearched] = useState(false);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setHasSearched(query.length > 0);
    // TODO: Implement actual search functionality
    console.log("Searching for:", query);
  };

  const handlePlayAlbum = (album: any) => {
    console.log("Playing album:", album);
  };

  if (!hasSearched) {
    return (
      <div className="space-y-8 pb-32">
        {/* Search Header */}
        <div className="space-y-4">
          <h1 className="text-3xl font-bold text-foreground">Search</h1>
          <SearchBar onSearch={handleSearch} />
        </div>

        {/* Recent Searches */}
        {recentSearches.length > 0 && (
          <section>
            <h2 className="text-xl font-semibold text-foreground mb-4">Recent Searches</h2>
            <div className="space-y-2">
              {recentSearches.map((search, index) => (
                <Button
                  key={index}
                  variant="ghost"
                  className="justify-start h-auto p-3 w-full"
                  onClick={() => handleSearch(search)}
                >
                  <Music className="h-4 w-4 mr-3 text-muted-foreground" />
                  <span className="text-foreground">{search}</span>
                </Button>
              ))}
            </div>
          </section>
        )}

        {/* Browse by Genre */}
        <section>
          <h2 className="text-xl font-semibold text-foreground mb-4">Browse All</h2>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {topGenres.map((genre) => (
              <Card
                key={genre.name}
                className={`${genre.color} p-6 cursor-pointer hover:scale-105 transition-transform`}
              >
                <h3 className="text-xl font-bold text-white">{genre.name}</h3>
              </Card>
            ))}
          </div>
        </section>
      </div>
    );
  }

  return (
    <div className="space-y-8 pb-32">
      {/* Search Header */}
      <div className="space-y-4">
        <h1 className="text-3xl font-bold text-foreground">Search Results</h1>
        <SearchBar onSearch={handleSearch} />
      </div>

      {/* Search Results */}
      <Tabs defaultValue="all" className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="all">All</TabsTrigger>
          <TabsTrigger value="tracks">Songs</TabsTrigger>
          <TabsTrigger value="albums">Albums</TabsTrigger>
          <TabsTrigger value="artists">Artists</TabsTrigger>
        </TabsList>

        <TabsContent value="all" className="space-y-8">
          {/* Top Result */}
          {searchResults.tracks[0] && (
            <section>
              <h2 className="text-xl font-semibold text-foreground mb-4">Top Result</h2>
              <Card className="p-6 hover:bg-accent/50 transition-colors">
                <div className="flex items-center gap-4">
                  <img
                    src={searchResults.tracks[0].cover}
                    alt={searchResults.tracks[0].title}
                    className="w-20 h-20 rounded-lg object-cover"
                  />
                  <div>
                    <h3 className="text-2xl font-bold text-foreground">
                      {searchResults.tracks[0].title}
                    </h3>
                    <p className="text-muted-foreground">
                      Song • {searchResults.tracks[0].artist}
                    </p>
                    <Button
                      className="mt-2 bg-music-primary hover:bg-music-primary/90"
                      onClick={() => onPlayTrack(searchResults.tracks[0])}
                    >
                      Play
                    </Button>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Songs */}
          <section>
            <h2 className="text-xl font-semibold text-foreground mb-4">Songs</h2>
            <div className="space-y-2">
              {searchResults.tracks.slice(0, 4).map((track) => (
                <TrackCard
                  key={track.id}
                  track={track}
                  isPlaying={currentTrack?.id === track.id && isPlaying}
                  onPlay={onPlayTrack}
                />
              ))}
            </div>
          </section>

          {/* Albums */}
          <section>
            <h2 className="text-xl font-semibold text-foreground mb-4">Albums</h2>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
              {searchResults.albums.map((album) => (
                <AlbumCard
                  key={album.id}
                  album={album}
                  onPlay={handlePlayAlbum}
                />
              ))}
            </div>
          </section>
        </TabsContent>

        <TabsContent value="tracks">
          <div className="space-y-2">
            {searchResults.tracks.map((track) => (
              <TrackCard
                key={track.id}
                track={track}
                isPlaying={currentTrack?.id === track.id && isPlaying}
                onPlay={onPlayTrack}
              />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="albums">
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
            {searchResults.albums.map((album) => (
              <AlbumCard
                key={album.id}
                album={album}
                onPlay={handlePlayAlbum}
              />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="artists">
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {searchResults.artists.map((artist) => (
              <Card key={artist.id} className="p-4 hover:bg-accent/50 transition-colors">
                <div className="text-center space-y-3">
                  <img
                    src={artist.image}
                    alt={artist.name}
                    className="w-24 h-24 rounded-full object-cover mx-auto"
                  />
                  <div>
                    <h3 className="font-semibold text-foreground">{artist.name}</h3>
                    <p className="text-sm text-muted-foreground">
                      {artist.followers} followers
                    </p>
                  </div>
                  <Button variant="outline" size="sm">
                    Follow
                  </Button>
                </div>
              </Card>
            ))}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}