import { useState, useEffect } from "react";
import { AlbumCard } from "@/components/AlbumCard";
import { TrackCard } from "@/components/TrackCard";
import { SearchBar } from "@/components/SearchBar";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { musicApiService, ApiTrack } from "@/services/musicApi";
import heroImage from "@/assets/hero-music.jpg";


interface HomeProps {
  onPlayTrack: (track: any) => void;
  currentTrack?: any;
  isPlaying: boolean;
}

export default function Home({ onPlayTrack, currentTrack, isPlaying }: HomeProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [featuredAlbums, setFeaturedAlbums] = useState<any[]>([]);
  const [popularTracks, setPopularTracks] = useState<ApiTrack[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Load data from API
  useEffect(() => {
    const loadData = async () => {
      try {
        setIsLoading(true);
        const [albums, tracks] = await Promise.all([
          musicApiService.getFeaturedAlbums(8),
          musicApiService.getPopularTracks(10)
        ]);
        setFeaturedAlbums(albums);
        setPopularTracks(tracks);
      } catch (error) {
        console.error('Error loading data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadData();
  }, []);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    // Navigate to search page with query
    window.location.href = `/search?q=${encodeURIComponent(query)}`;
  };

  const handlePlayAlbum = (album: any) => {
    if (album.tracks && album.tracks.length > 0) {
      onPlayTrack(album.tracks[0]);
    }
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
        {isLoading ? (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="space-y-3">
                <Skeleton className="w-full h-40 rounded-lg" />
                <Skeleton className="h-4 w-3/4" />
                <Skeleton className="h-3 w-1/2" />
              </div>
            ))}
          </div>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
            {featuredAlbums.map((album) => (
              <AlbumCard
                key={album.id}
                album={album}
                onPlay={handlePlayAlbum}
              />
            ))}
          </div>
        )}
      </section>

      {/* Trending Now */}
      <section>
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-foreground">Popular Tracks</h2>
          <Button variant="ghost">View All</Button>
        </div>
        {isLoading ? (
          <div className="space-y-2">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 p-3">
                <Skeleton className="w-12 h-12 rounded-md" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-4 w-3/4" />
                  <Skeleton className="h-3 w-1/2" />
                </div>
                <Skeleton className="h-4 w-12" />
              </div>
            ))}
          </div>
        ) : (
          <div className="space-y-2">
            {popularTracks.slice(0, 5).map((track, index) => (
              <TrackCard
                key={track.id}
                track={track}
                isPlaying={currentTrack?.id === track.id && isPlaying}
                onPlay={onPlayTrack}
                index={index}
              />
            ))}
          </div>
        )}
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