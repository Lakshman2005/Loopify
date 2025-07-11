import { useState } from "react";
import { AlbumCard } from "@/components/AlbumCard";
import { TrackCard } from "@/components/TrackCard";
import { SearchBar } from "@/components/SearchBar";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import heroImage from "@/assets/hero-music.jpg";

// Mock data
const featuredAlbums = [
  {
    id: "1",
    title: "Midnight Vibes",
    artist: "Luna Echo",
    cover: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop&crop=faces",
    year: 2024,
    trackCount: 12
  },
  {
    id: "2",
    title: "Electric Dreams",
    artist: "Neon Pulse",
    cover: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=400&fit=crop&crop=faces",
    year: 2024,
    trackCount: 10
  },
  {
    id: "3",
    title: "Ocean Waves",
    artist: "Coastal",
    cover: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop&crop=faces",
    year: 2023,
    trackCount: 8
  },
  {
    id: "4",
    title: "Urban Jungle",
    artist: "City Sounds",
    cover: "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&h=400&fit=crop&crop=faces",
    year: 2024,
    trackCount: 15
  },
];

const trendingTracks = [
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
  {
    id: "3",
    title: "Waves",
    artist: "Coastal",
    album: "Ocean Waves",
    duration: 267,
    cover: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop&crop=faces"
  },
];

interface HomeProps {
  onPlayTrack: (track: any) => void;
  currentTrack?: any;
  isPlaying: boolean;
}

export default function Home({ onPlayTrack, currentTrack, isPlaying }: HomeProps) {
  const [searchQuery, setSearchQuery] = useState("");

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    // TODO: Implement search functionality
    console.log("Searching for:", query);
  };

  const handlePlayAlbum = (album: any) => {
    // TODO: Play first track of album
    console.log("Playing album:", album);
  };

  return (
    <div className="space-y-8 pb-32">
      {/* Hero Section */}
      <Card className="relative overflow-hidden">
        <div 
          className="h-64 md:h-96 bg-cover bg-center relative"
          style={{ backgroundImage: `url(${heroImage})` }}
        >
          <div className="absolute inset-0 bg-gradient-to-r from-background/80 via-background/40 to-transparent" />
          <div className="absolute inset-0 flex items-center justify-center md:justify-start">
            <div className="text-center md:text-left md:ml-12 space-y-4">
              <h1 className="text-4xl md:text-6xl font-bold text-white drop-shadow-lg">
                Your Music,
                <br />
                <span className="text-music-primary">Your Way</span>
              </h1>
              <p className="text-lg md:text-xl text-white/90 drop-shadow max-w-md">
                Discover millions of songs, create playlists, and enjoy high-quality streaming
              </p>
              <div className="flex flex-col sm:flex-row gap-4 items-center justify-center md:justify-start">
                <SearchBar onSearch={handleSearch} />
                <Button size="lg" className="bg-music-primary hover:bg-music-primary/90">
                  Start Listening
                </Button>
              </div>
            </div>
          </div>
        </div>
      </Card>

      {/* Featured Albums */}
      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-foreground">Featured Albums</h2>
          <Button variant="ghost">View All</Button>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
          {featuredAlbums.map((album) => (
            <AlbumCard
              key={album.id}
              album={album}
              onPlay={handlePlayAlbum}
            />
          ))}
        </div>
      </section>

      {/* Trending Now */}
      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-foreground">Trending Now</h2>
          <Button variant="ghost">View All</Button>
        </div>
        <div className="space-y-2">
          {trendingTracks.map((track, index) => (
            <TrackCard
              key={track.id}
              track={track}
              isPlaying={currentTrack?.id === track.id && isPlaying}
              onPlay={onPlayTrack}
              index={index}
            />
          ))}
        </div>
      </section>

      {/* Made For You */}
      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-foreground">Made For You</h2>
          <Button variant="ghost">View All</Button>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
          {featuredAlbums.slice(0, 3).map((album) => (
            <AlbumCard
              key={`made-for-you-${album.id}`}
              album={album}
              onPlay={handlePlayAlbum}
            />
          ))}
        </div>
      </section>
    </div>
  );
}